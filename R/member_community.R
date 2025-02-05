#' Community graph partitioning algorithms
#' @inheritParams is
#' @name community
#' @family memberships
NULL

#' @describeIn community A greedy, iterative, deterministic graph
#'   partitioning algorithm that results in a graph with two 
#'   equally-sized communities
#' @references
#' Kernighan, Brian W., and Shen Lin. 1970.
#' "An efficient heuristic procedure for partitioning graphs."
#' _The Bell System Technical Journal_ 49(2): 291-307.
#' \doi{10.1002/j.1538-7305.1970.tb01770.x}
#' @examples
#' node_kernighanlin(ison_adolescents)
#' node_kernighanlin(ison_southern_women)
#' @export
node_kernighanlin <- function(.data){
  # assign groups arbitrarily
  n <- manynet::network_nodes(.data)
  group_size <- ifelse(n %% 2 == 0, n/2, (n+1)/2)
  
  # count internal and external costs of each vertex
  g <- manynet::as_matrix(manynet::to_multilevel(.data))
  g1 <- g[1:group_size, 1:group_size]
  g2 <- g[(group_size+1):n, (group_size+1):n]
  intergroup <- g[1:group_size, (group_size+1):n]
  
  g2.intcosts <- rowSums(g2)
  g2.extcosts <- colSums(intergroup)
  
  g1.intcosts <- rowSums(g1)
  g1.extcosts <- rowSums(intergroup)
  
  # count edge costs of each vertex
  g1.net <- g1.extcosts - g1.intcosts
  g2.net <- g2.extcosts - g2.intcosts
  
  g1.net <- sort(g1.net, decreasing = TRUE)
  g2.net <- sort(g2.net, decreasing = TRUE)
  
  # swap pairs of vertices (one from each group) that give a positive sum of net edge costs
  if(length(g1.net)!=length(g2.net)) {
    g2.net <- c(g2.net,0)
  } else {g2.net}
  
  sums <- as.integer(unname(g1.net + g2.net))
  # positions in sequence of names at which sum >= 0
  index <- which(sums >= 0 %in% sums)
  g1.newnames <- g1.names <- names(g1.net)
  g2.newnames <- g2.names <- names(g2.net)
  # make swaps based on positions in sequence
  for (i in index) {
    g1.newnames[i] <- g2.names[i]
    g2.newnames[i] <- g1.names[i]
  }
  
  # extract names of vertices in each group after swaps
  out <- ifelse(manynet::node_names(.data) %in% g1.newnames, 1, 2)
  if(manynet::is_labelled(.data)) names(out) <- manynet::node_names(.data)
  make_node_member(out, .data)
}

#' @describeIn community A hierarchical, agglomerative algorithm based on random walks.
#' @section Walktrap:
#'   The general idea is that random walks on a network are more likely to stay 
#'   within the same community because few edges lead outside a community.
#'   By repeating random walks of 4 steps many times,
#'   information about the hierarchical merging of communities is collected.
#' @param times Integer indicating number of simulations/walks used.
#'   By default, `times=50`.
#' @examples
#' node_walktrap(ison_adolescents)
#' @export
node_walktrap <- function(.data, times = 50){
  out <- igraph::cluster_walktrap(manynet::as_igraph(.data), 
                           steps=times)$membership
  make_node_member(out, .data)
  
}

#' @describeIn community A hierarchical, decomposition algorithm
#'   where edges are removed in decreasing order of the number of
#'   shortest paths passing through the edge,
#'   resulting in a hierarchical representation of group membership.
#' @section Edge-betweenness:
#'   This is motivated by the idea that edges connecting different groups 
#'   are more likely to lie on multiple shortest paths when they are the 
#'   only option to go from one group to another. 
#'   This method yields good results but is very slow because of 
#'   the computational complexity of edge-betweenness calculations and 
#'   the betweenness scores have to be re-calculated after every edge removal. 
#'   Networks of ~700 nodes and ~3500 ties are around the upper size limit 
#'   that are feasible with this approach. 
#' @examples
#' node_edge_betweenness(ison_adolescents)
#' @export
node_edge_betweenness <- function(.data){
  out <- suppressWarnings(igraph::cluster_edge_betweenness(
    manynet::as_igraph(.data))$membership)
  make_node_member(out, .data)
}

#' @describeIn community A hierarchical, agglomerative algorithm, 
#'   that tries to optimize modularity in a greedy manner.
#' @section Fast-greedy:
#'   Initially, each node is assigned a separate community.
#'   Communities are then merged iteratively such that each merge
#'   yields the largest increase in the current value of modularity,
#'   until no further increases to the modularity are possible.
#'   The method is fast and recommended as a first approximation 
#'   because it has no parameters to tune. 
#'   However, it is known to suffer from a resolution limit.
#' @examples
#' node_fast_greedy(ison_adolescents)
#' @export
node_fast_greedy <- function(.data){
  out <- igraph::cluster_fast_greedy(manynet::as_igraph(.data)
  )$membership
  make_node_member(out, .data)
}