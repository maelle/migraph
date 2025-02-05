% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mark_ties.R
\name{mark_ties}
\alias{mark_ties}
\alias{tie_is_multiple}
\alias{tie_is_loop}
\alias{tie_is_reciprocated}
\alias{tie_is_bridge}
\alias{tie_is_max}
\alias{tie_is_min}
\title{Marking ties based on their properties}
\usage{
tie_is_multiple(.data)

tie_is_loop(.data)

tie_is_reciprocated(.data)

tie_is_bridge(.data)

tie_is_max(tie_measure)

tie_is_min(tie_measure)
}
\arguments{
\item{.data}{An object of a \code{{manynet}}-consistent class:
\itemize{
\item matrix (adjacency or incidence) from \code{{base}} R
\item edgelist, a data frame from \code{{base}} R or tibble from \code{{tibble}}
\item igraph, from the \code{{igraph}} package
\item network, from the \code{{network}} package
\item tbl_graph, from the \code{{tidygraph}} package
}}

\item{tie_measure}{An object created by a \code{tie_} measure.}
}
\description{
These functions return logical vectors the length of the ties
in a network, identifying which hold some property.
They are most useful in highlighting parts of the network that
are particularly well- or poorly-connected.
}
\section{Functions}{
\itemize{
\item \code{tie_is_multiple()}: Returns logical of which ties are multiples

\item \code{tie_is_loop()}: Returns logical of which ties are loops

\item \code{tie_is_reciprocated()}: Returns logical of which ties
are mutual/reciprocated

\item \code{tie_is_bridge()}: Returns logical of which ties cut
or act as articulation points in a network.

\item \code{tie_is_max()}: Returns logical of which ties
hold the maximum of some measure

\item \code{tie_is_min()}: Returns logical of which ties
hold the minimum of some measure

}}
\examples{
tie_is_multiple(ison_marvel_relationships)
tie_is_loop(ison_marvel_relationships)
tie_is_reciprocated(ison_algebra)
tie_is_bridge(ison_brandes)
tie_is_max(tie_betweenness(ison_brandes))
tie_is_min(tie_betweenness(ison_brandes))
}
\seealso{
Other marks: 
\code{\link{is}()},
\code{\link{mark_nodes}}
}
\concept{marks}
