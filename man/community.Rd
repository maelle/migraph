% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/member_community.R
\name{community}
\alias{community}
\alias{node_kernighanlin}
\alias{node_walktrap}
\alias{node_edge_betweenness}
\alias{node_fast_greedy}
\title{Community graph partitioning algorithms}
\usage{
node_kernighanlin(.data)

node_walktrap(.data, times = 50)

node_edge_betweenness(.data)

node_fast_greedy(.data)
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

\item{times}{Integer indicating number of simulations/walks used.
By default, \code{times=50}.}
}
\description{
Community graph partitioning algorithms
}
\section{Functions}{
\itemize{
\item \code{node_kernighanlin()}: A greedy, iterative, deterministic graph
partitioning algorithm that results in a graph with two
equally-sized communities

\item \code{node_walktrap()}: A hierarchical, agglomerative algorithm based on random walks.

\item \code{node_edge_betweenness()}: A hierarchical, decomposition algorithm
where edges are removed in decreasing order of the number of
shortest paths passing through the edge,
resulting in a hierarchical representation of group membership.

\item \code{node_fast_greedy()}: A hierarchical, agglomerative algorithm,
that tries to optimize modularity in a greedy manner.

}}
\section{Walktrap}{

The general idea is that random walks on a network are more likely to stay
within the same community because few edges lead outside a community.
By repeating random walks of 4 steps many times,
information about the hierarchical merging of communities is collected.
}

\section{Edge-betweenness}{

This is motivated by the idea that edges connecting different groups
are more likely to lie on multiple shortest paths when they are the
only option to go from one group to another.
This method yields good results but is very slow because of
the computational complexity of edge-betweenness calculations and
the betweenness scores have to be re-calculated after every edge removal.
Networks of ~700 nodes and ~3500 ties are around the upper size limit
that are feasible with this approach.
}

\section{Fast-greedy}{

Initially, each node is assigned a separate community.
Communities are then merged iteratively such that each merge
yields the largest increase in the current value of modularity,
until no further increases to the modularity are possible.
The method is fast and recommended as a first approximation
because it has no parameters to tune.
However, it is known to suffer from a resolution limit.
}

\examples{
node_kernighanlin(ison_adolescents)
node_kernighanlin(ison_southern_women)
node_walktrap(ison_adolescents)
node_edge_betweenness(ison_adolescents)
node_fast_greedy(ison_adolescents)
}
\references{
Kernighan, Brian W., and Shen Lin. 1970.
"An efficient heuristic procedure for partitioning graphs."
\emph{The Bell System Technical Journal} 49(2): 291-307.
\doi{10.1002/j.1538-7305.1970.tb01770.x}
}
\seealso{
Other memberships: 
\code{\link{components}()},
\code{\link{core-periphery}},
\code{\link{equivalence}}
}
\concept{memberships}
