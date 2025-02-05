% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/measure_heterogeneity.R
\name{heterogeneity}
\alias{heterogeneity}
\alias{network_richness}
\alias{node_richness}
\alias{network_diversity}
\alias{node_diversity}
\alias{network_heterophily}
\alias{node_heterophily}
\alias{network_assortativity}
\title{Measures of network diversity}
\usage{
network_richness(.data, attribute)

node_richness(.data, attribute)

network_diversity(.data, attribute, clusters = NULL)

node_diversity(.data, attribute)

network_heterophily(.data, attribute)

node_heterophily(.data, attribute)

network_assortativity(.data)
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

\item{attribute}{Name of a nodal attribute or membership vector
to use as categories for the diversity measure.}

\item{clusters}{A nodal cluster membership vector or name of a vertex attribute.}
}
\description{
These functions offer ways to summarise the heterogeneity of an attribute
across a network, within groups of a network, or the distribution of ties
across this attribute.
}
\section{Functions}{
\itemize{
\item \code{network_richness()}: Calculates the number of unique categories
in a network attribute.

\item \code{node_richness()}: Calculates the number of unique categories
of an attribute to which each node is connected.

\item \code{network_diversity()}: Calculates the heterogeneity of ties across a network or
within clusters by node attributes.

\item \code{node_diversity()}: Calculates the heterogeneity of each node's
local neighbourhood.

\item \code{network_heterophily()}: Calculates how embedded nodes in the network
are within groups of nodes with the same attribute

\item \code{node_heterophily()}: Calculates each node's embeddedness within groups
of nodes with the same attribute

\item \code{network_assortativity()}: Calculates the degree assortativity in a graph.

}}
\section{network_diversity}{

Blau's index (1977) uses a formula known also in other disciplines
by other names
(Gini-Simpson Index, Gini impurity, Gini's diversity index,
Gibbs-Martin index, and probability of interspecific encounter (PIE)):
\deqn{1 - \sum\limits_{i = 1}^k {p_i^2 }},
where \eqn{p_i} is the proportion of group members in \eqn{i}th category
and \eqn{k} is the number of categories for an attribute of interest.
This index can be interpreted as the probability that two members
randomly selected from a group would be from different categories.
This index finds its minimum value (0) when there is no variety,
i.e. when all individuals are classified in the same category.
The maximum value depends on the number of categories and
whether nodes can be evenly distributed across categories.
}

\section{network_homophily}{

Given a partition of a network into a number of mutually exclusive groups then
The E-I index is the number of ties between (or \emph{external}) nodes
grouped in some mutually exclusive categories
minus the number of ties within (or \emph{internal}) these groups
divided by the total number of ties.
This value can range from 1 to -1,
where 1 indicates ties only between categories/groups and -1 ties only within categories/groups.
}

\examples{
network_richness(mpn_bristol)
node_richness(mpn_bristol, "type")
marvel_friends <- manynet::to_unsigned(manynet::ison_marvel_relationships, "positive")
network_diversity(marvel_friends, "Gender")
network_diversity(marvel_friends, "Attractive")
network_diversity(marvel_friends, "Gender", "Rich")
node_diversity(marvel_friends, "Gender")
node_diversity(marvel_friends, "Attractive")
network_heterophily(marvel_friends, "Gender")
network_heterophily(marvel_friends, "Attractive")
node_heterophily(marvel_friends, "Gender")
node_heterophily(marvel_friends, "Attractive")
network_assortativity(mpn_elite_mex)
}
\references{
Blau, Peter M. (1977).
\emph{Inequality and heterogeneity}.
New York: Free Press.

Krackhardt, David and Robert N. Stern (1988).
Informal networks and organizational crises: an experimental simulation.
\emph{Social Psychology Quarterly} 51(2), 123-140.
}
\seealso{
Other measures: 
\code{\link{between_centrality}},
\code{\link{close_centrality}},
\code{\link{closure}},
\code{\link{cohesion}()},
\code{\link{degree_centrality}},
\code{\link{eigenv_centrality}},
\code{\link{features}},
\code{\link{holes}}
}
\concept{measures}
