#' Measures of network cohesion or connectedness
#' 
#' These functions return values or vectors relating to how connected a network is
#' and the number of nodes or edges to remove that would increase fragmentation.
#' @inheritParams is
#' @name cohesion
#' @family measures
NULL

#' @describeIn cohesion Summarises the ratio of ties
#' to the number of possible ties.
#' @importFrom igraph edge_density
#' @examples 
#' network_density(mpn_elite_mex)
#' network_density(mpn_elite_usa_advice)
#' @export
network_density <- function(.data) {
  if (is_twomode(.data)) {
    mat <- manynet::as_matrix(.data)
    out <- sum(mat) / (nrow(mat) * ncol(mat))
  } else {
    out <- igraph::edge_density(manynet::as_igraph(.data))
  }
  make_network_measure(out, .data)
}

#' @describeIn cohesion Returns number of (strong) components in the network.
#'   To get the 'weak' components of a directed graph, 
#'   please use `manynet::to_undirected()` first.
#' @importFrom igraph components
#' @examples
#' network_components(mpn_ryanair)
#' network_components(manynet::to_undirected(mpn_ryanair))
#' @export
network_components <- function(.data){
  object <- manynet::as_igraph(.data)
  make_network_measure(igraph::components(object, mode = "strong")$no,
                       object)
}

#' @describeIn cohesion Returns the minimum number of nodes to remove
#'   from the network needed to increase the number of components.
#' @importFrom igraph cohesion
#' @references
#' White, Douglas R and Frank Harary. 2001. 
#' "The Cohesiveness of Blocks In Social Networks: Node Connectivity and Conditional Density." 
#' _Sociological Methodology_ 31(1): 305-59.
#' @examples 
#' network_cohesion(manynet::ison_marvel_relationships)
#' network_cohesion(manynet::to_giant(manynet::ison_marvel_relationships))
#' @export
network_cohesion <- function(.data){
  make_network_measure(igraph::cohesion(manynet::as_igraph(.data)), .data)
}

#' @describeIn cohesion Returns the minimum number of edges needed
#'   to remove from the network to increase the number of components.
#' @importFrom igraph adhesion
#' @examples 
#' network_adhesion(manynet::ison_marvel_relationships)
#' network_adhesion(manynet::to_giant(manynet::ison_marvel_relationships))
#' @export
network_adhesion <- function(.data){
  make_network_measure(igraph::adhesion(manynet::as_igraph(.data)), .data)
}

#' @describeIn cohesion Returns the maximum path length in the network.
#' @importFrom igraph diameter
#' @examples 
#' network_diameter(manynet::ison_marvel_relationships)
#' network_diameter(manynet::to_giant(manynet::ison_marvel_relationships))
#' @export
network_diameter <- function(.data){
  object <- manynet::as_igraph(.data)
  make_network_measure(igraph::diameter(object, directed = is_directed(object)),
                       object)
}

#' @describeIn cohesion Returns the average path length in the network.
#' @importFrom igraph mean_distance
#' @examples 
#' network_length(manynet::ison_marvel_relationships)
#' network_length(manynet::to_giant(manynet::ison_marvel_relationships))
#' @export
network_length <- function(.data){
  object <- manynet::as_igraph(.data)
  make_network_measure(igraph::mean_distance(object,
                                             directed = is_directed(object)),
                       object)
}
