#' Censuses of nodes' motifs
#' 
#' @description
#' These functions include ways to take a census of the positions of nodes
#' in a network. These include a triad census based on the triad profile
#' of nodes, but also a tie census based on the particular tie partners
#' of nodes. Included also are group census functions for summarising
#' the profiles of clusters of nodes in a network.
#' @name node_census
#' @family motifs
#' @inheritParams is
#' @importFrom igraph vcount graph.neighborhood delete_vertices triad_census
NULL

#' @describeIn node_census Returns a census of the ties in a network.
#'   For directed networks, out-ties and in-ties are bound together.
#' @examples
#' task_eg <- manynet::to_named(manynet::to_uniplex(manynet::ison_algebra, "task_tie"))
#' (tie_cen <- node_tie_census(task_eg))
#' @export
node_tie_census <- function(.data){
  object <- manynet::as_igraph(.data)
  edge_names <- igraph::edge_attr_names(object)
  if (manynet::is_directed(object)) {
    mat <- vector()
    if (length(edge_names) > 0) {
      for (e in edge_names) {
        rc <- igraph::as_adjacency_matrix(object, attr = e, sparse = F)
        rccr <- rbind(rc, t(rc))
        mat <- rbind(mat, rccr)
      }} else {
        rc <- igraph::as_adjacency_matrix(object, sparse = F)
        rccr <- rbind(rc, t(rc))
        mat <- rbind(mat, rccr)
      }
  } else {
    mat <- vector() 
    if (length(edge_names) > 0) {
      for (e in edge_names) {
        rc <- igraph::as_adjacency_matrix(object, attr = e, sparse = F)
        mat <- rbind(mat, rc)
      }} else {
        rc <- igraph::as_adjacency_matrix(object, sparse = F)
        mat <- rbind(mat, rc)
      }
  }
  if(manynet::is_labelled(object) & manynet::is_directed(object))
    if(length(edge_names) > 0){
      rownames(mat) <- apply(expand.grid(c(paste0("from", igraph::V(object)$name),
                                           paste0("to", igraph::V(object)$name)),
                                         edge_names), 
                             1, paste, collapse = "_")
    } else {
      rownames(mat) <- rep(c(paste0("from", igraph::V(object)$name),
                             paste0("to", igraph::V(object)$name)))
    }
  make_node_motif(t(mat), object)
}

#' @describeIn node_census Returns a census of the triad configurations
#'   nodes are embedded in.
#' @references 
#' Davis, James A., and Samuel Leinhardt. 1967. 
#' “\href{https://files.eric.ed.gov/fulltext/ED024086.pdf}{The Structure of Positive Interpersonal Relations in Small Groups}.” 55.
#' @examples 
#' (triad_cen <- node_triad_census(task_eg))
#' @export
node_triad_census <- function(.data){
  x <- manynet::as_igraph(.data)
  out <- vector() # This line intialises an empty vector
  for (i in seq_len(igraph::vcount(x))) { # For each (i) in 
    nb.wi <- igraph::graph.neighborhood(x,
                                        order = 1,
                                        V(x)[i],
                                        mode = 'all')[[1]] 
    # Get i's local neighbourhood. See also make_ego_graph()
    nb.wi <- nb.wi + (igraph::vcount(x) - igraph::vcount(nb.wi)) 
    # Add the removed vertices back in (empty) for symmetry
    nb.wo <- igraph::delete_vertices(nb.wi, i)
    # Make a graph without i in it
    out <- rbind(out,
                 suppressWarnings(igraph::triad_census(nb.wi)) - 
                   suppressWarnings(igraph::triad_census(nb.wo)) )
    # Get the difference in triad census between the local graph
    # with and without i to get i's triad census
  } # Close the for loop
  colnames(out) <- c("003", "012", "102", "021D",
                     "021U", "021C", "111D", "111U",
                     "030T", "030C", "201", "120D",
                     "120U", "120C", "210", "300")
  if (!manynet::is_directed(.data)) out <- out[, c(1, 2, 3, 11, 15, 16)]
  rownames(out) <- igraph::V(x)$name
  make_node_motif(out, .data)
}

#' @describeIn node_census Returns a census of nodes' positions
#'   in motifs of four nodes.
#' @details The quad census uses the `{oaqc}` package to do
#'   the heavy lifting of counting the number of each orbits.
#'   See `vignette('oaqc')`.
#'   However, our function relabels some of the motifs
#'   to avoid conflicts and improve some consistency with 
#'   other census-labelling practices.
#'   The letter-number pairing of these labels indicate
#'   the number and configuration of ties.
#'   For now, we offer a rough translation:
#'   
#' | migraph | Ortmann and Brandes      
#' | ------------- |------------- |
#' | E4  | co-K4
#' | I40, I41  | co-diamond
#' | H4  | co-C4
#' | L42, L41, L40 | co-paw
#' | D42, D40 | co-claw
#' | U42, U41 | P4
#' | Y43, Y41 | claw
#' | P43, P42, P41 | paw
#' | 04 | C4
#' | Z42, Z43 | diamond
#' | X4 | K4
#' 
#' See also [this list of graph classes](https://www.graphclasses.org/smallgraphs.html#nodes4).
#' @importFrom tidygraph %E>%
#' @references 
#'  Ortmann, Mark, and Ulrik Brandes. 2017. 
#'  “Efficient Orbit-Aware Triad and Quad Census in Directed and Undirected Graphs.” 
#'  \emph{Applied Network Science} 2(1):13. 
#'  \doi{10.1007/s41109-017-0027-2}.
#' @examples 
#' node_quad_census(manynet::ison_southern_women)
#' @export
node_quad_census <- function(.data){
  if (!("oaqc" %in% rownames(utils::installed.packages()))) {
    message("Please install package `{oaqc}`.")
  } else {
    graph <- .data %>% manynet::as_tidygraph() %E>% 
      as.data.frame()
    out <- oaqc::oaqc(graph)[[1]]
    out <- out[-1,]
    rownames(out) <- manynet::node_names(.data)
    colnames(out) <- c("E4", # co-K4
                       "I41","I40", # co-diamond
                       "H4", # co-C4
                       "L42","L41","L40", # co-paw
                       "D42","D40", # co-claw
                       "U42","U41", # P4
                       "Y43","Y41", # claw
                       "P43","P42","P41", # paw
                       "04", # C4
                       "Z42","Z43", # diamond
                       "X4") # K4
    if(manynet::is_twomode(.data)) out <- out[,-c(8,9,14,15,16,18,19,20)]
    make_node_motif(out, .data)
  }
}

#' #' @export
#' node_bmotif_census <- function(.data, normalized = FALSE){
#'   if (!("bmotif" %in% rownames(utils::installed.packages()))) {
#'     message("Please install package `{bmotif}`.")
#'     out <- bmotif::node_positions(manynet::as_matrix(.data), 
#'                                   weights_method = ifelse(manynet::is_weighted(.data),
#'                                                           'mean_motifweights', 'none'),
#'                                   normalisation = ifelse(normalized, 
#'                                                          'levelsize_NAzero', 'none'))
#'     make_node_motif(out, .data)
#'   }
#' }
#' 
#' #' @export
#' node_igraph_census <- function(.data, normalized = FALSE){
#'     out <- igraph::motifs(manynet::as_igraph(.data), 4)
#'     if(manynet::is_labelled(.data))
#'       rownames(out) <- manynet::node_names(.data)
#'     colnames(out) <- c("co-K4",
#'                        "co-diamond",
#'                        "co-C4",
#'                        "co-paw",
#'                        "co-claw",
#'                        "P4",
#'                        "claw",
#'                        "paw",
#'                        "C4",
#'                        "diamond",
#'                        "K4")
#'     make_node_motif(out, .data)
#' }

#' @describeIn node_census Returns the shortest path lengths
#'   of each node to every other node in the network.
#' @importFrom igraph distances
#' @references 
#' Dijkstra, Edsger W. 1959. 
#' "A note on two problems in connexion with graphs". 
#' _Numerische Mathematik_ 1, 269-71.
#' \doi{10.1007/BF01386390}.
#' 
#' Opsahl, Tore, Filip Agneessens, and John Skvoretz. 2010.
#' "Node centrality in weighted networks: Generalizing degree and shortest paths". 
#' _Social Networks_ 32(3): 245-51.
#' \doi{10.1016/j.socnet.2010.03.006}.
#' @examples 
#' node_path_census(manynet::ison_adolescents)
#' node_path_census(manynet::ison_southern_women)
#' @export
node_path_census <- function(.data){
  if(manynet::is_weighted(.data)){
    tore <- manynet::as_matrix(.data)/mean(manynet::as_matrix(.data))
    out <- 1/tore
  } else out <- igraph::distances(manynet::as_igraph(.data))
  diag(out) <- 0
  make_node_motif(out, .data)
}

#' Censuses of motifs at the network level
#' 
#' @name network_census
#' @family motifs
#' @inheritParams node_census
#' @param object2 A second, two-mode migraph-consistent object.
NULL

#' @describeIn network_census Returns a census of dyad motifs in a network
#' @examples 
#' network_dyad_census(manynet::ison_algebra)
#' @export
network_dyad_census <- function(.data) {
  if (manynet::is_twomode(.data)) {
    stop("A twomode or multilevel option for a dyad census is not yet implemented.")
  } else {
    out <- suppressWarnings(igraph::dyad_census(manynet::as_igraph(.data)))
    out <- unlist(out)
    names(out) <- c("Mutual", "Asymmetric", "Null")
    if (!manynet::is_directed(.data)) out <- out[c(1, 3)]
    make_network_motif(out, .data)
  }
}

#' @describeIn network_census Returns a census of triad motifs in a network
#' @references 
#' Davis, James A., and Samuel Leinhardt. 1967. 
#' “\href{https://files.eric.ed.gov/fulltext/ED024086.pdf}{The Structure of Positive Interpersonal Relations in Small Groups}.” 55.
#' @examples 
#' network_triad_census(manynet::ison_adolescents)
#' @export
network_triad_census <- function(.data) {
  if (manynet::is_twomode(.data)) {
    stop("A twomode or multilevel option for a triad census is not yet implemented.")
  } else {
    out <- suppressWarnings(igraph::triad_census(as_igraph(.data)))
    names(out) <- c("003", "012", "102", "021D",
                    "021U", "021C", "111D", "111U",
                    "030T", "030C", "201", "120D",
                    "120U", "120C", "210", "300")
    if (!manynet::is_directed(.data)) out <- out[c(1, 2, 3, 11, 15, 16)]
    make_network_motif(out, .data)
  }
}

#' @describeIn network_census Returns a census of triad motifs that span
#'   a one-mode and a two-mode network
#' @source Alejandro Espinosa 'netmem'
#' @references 
#' Hollway, James, Alessandro Lomi, Francesca Pallotti, and Christoph Stadtfeld. 2017.
#' “Multilevel Social Spaces: The Network Dynamics of Organizational Fields.” 
#' _Network Science_ 5(2): 187–212.
#' \doi{10.1017/nws.2017.8}
#' @examples 
#' marvel_friends <- manynet::to_unsigned(manynet::ison_marvel_relationships, "positive")
#' (mixed_cen <- network_mixed_census(marvel_friends, manynet::ison_marvel_teams))
#' @export
network_mixed_census <- function (.data, object2) {
  if(manynet::is_twomode(.data))
    stop("First object should be a one-mode network")
  if(!manynet::is_twomode(object2))
    stop("Second object should be a two-mode network")
  if(manynet::network_dims(.data)[1] != manynet::network_dims(object2)[1])
    stop("Non-conformable arrays")
  m1 <- manynet::as_matrix(.data)
  m2 <- manynet::as_matrix(object2)
  cp <- function(m) (-m + 1)
  onemode.reciprocal <- m1 * t(m1)
  onemode.forward <- m1 * cp(t(m1))
  onemode.backward <- cp(m1) * t(m1)
  onemode.null <- cp(m1) * cp(t(m1))
  diag(onemode.forward) <- 0
  diag(onemode.backward) <- 0
  diag(onemode.null) <- 0
  bipartite.twopath <- m2 %*% t(m2)
  bipartite.null <- cp(m2) %*% cp(t(m2))
  bipartite.onestep1 <- m2 %*% cp(t(m2))
  bipartite.onestep2 <- cp(m2) %*% t(m2)
  diag(bipartite.twopath) <- 0
  diag(bipartite.null) <- 0
  diag(bipartite.onestep1) <- 0
  diag(bipartite.onestep2) <- 0
  res <- c("22" = sum(onemode.reciprocal * bipartite.twopath) / 2,
           "21" = sum(onemode.forward * bipartite.twopath) / 2 + sum(onemode.backward * bipartite.twopath) / 2,
           "20" = sum(onemode.null * bipartite.twopath) / 2,
           "12" = sum(onemode.reciprocal * bipartite.onestep1) / 2 + sum(onemode.reciprocal * bipartite.onestep2) / 2,
           "11D" = sum(onemode.forward * bipartite.onestep1) / 2 + sum(onemode.backward * bipartite.onestep2) / 2,
           "11U" = sum(onemode.forward * bipartite.onestep2) / 2 + sum(onemode.backward * bipartite.onestep1) / 2,
           "10" = sum(onemode.null * bipartite.onestep2) / 2 + sum(onemode.null * bipartite.onestep1) / 2,
           "02" = sum(onemode.reciprocal * bipartite.null) / 2,
           "01" = sum(onemode.forward * bipartite.null) / 2 + sum(onemode.backward * bipartite.null) / 2,
           "00" = sum(onemode.null * bipartite.null) / 2)  
  make_network_motif(res, .data)
}

#' Censuses of brokerage motifs
#' 
#' @name brokerage_census
#' @family motifs
#' @inheritParams node_census
#' @param membership A vector of partition membership as integers.
#' @param standardized Whether the score should be standardized
#'   into a _z_-score indicating how many standard deviations above
#'   or below the average the score lies.
NULL

#' @describeIn brokerage_census Returns the Gould-Fernandez brokerage
#'   roles played by nodes in a network.
#' @importFrom sna brokerage
#' @references 
#' Gould, R.V. and Fernandez, R.M. 1989. 
#' “Structures of Mediation: A Formal Approach to Brokerage in Transaction Networks.” 
#' _Sociological Methodology_, 19: 89-126.
#' @examples 
#' node_brokerage_census(manynet::ison_networkers, "Discipline")
#' @export
node_brokerage_census <- function(.data, membership, standardized = FALSE){
  out <- sna::brokerage(manynet::as_network(.data),
                        manynet::node_attribute(.data, membership))
  out <- if(standardized) out$z.nli else out$raw.nli
  colnames(out) <- c("Coordinator", "Itinerant", "Gatekeeper", 
                     "Representative", "Liaison", "Total")
  make_node_motif(out, .data)
}

#' @describeIn brokerage_census Returns the Gould-Fernandez brokerage
#'   roles in a network.
#' @examples 
#' network_brokerage_census(manynet::ison_networkers, "Discipline")
#' @export
network_brokerage_census <- function(.data, membership, standardized = FALSE){
  out <- sna::brokerage(manynet::as_network(.data),
                        manynet::node_attribute(.data, membership))
  out <- if(standardized) out$z.gli else out$raw.gli
  names(out) <- c("Coordinator", "Itinerant", "Gatekeeper", 
                     "Representative", "Liaison", "Total")
  make_network_motif(out, .data)
}
