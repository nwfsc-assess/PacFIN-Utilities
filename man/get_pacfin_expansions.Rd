% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_pacfin_expansions.R
\name{get_pacfin_expansions}
\alias{get_pacfin_expansions}
\title{Expand bds data up to the tow and catch level}
\usage{
get_pacfin_expansions(
  Pdata,
  Catch,
  weight_length_estimates,
  stratification.cols,
  Units = "MT",
  maxExp = 0.95,
  Exp_WA = TRUE,
  verbose = TRUE,
  savedir = NULL
)
}
\arguments{
\item{Pdata}{A data frame returned from \code{\link[=PullBDS.PacFIN]{PullBDS.PacFIN()}} containing
biological samples. These data are stored in the Pacific Fishieries
Information Network (PacFIN) data warehouse, which originated in 2014 and
are pulled using sql calls.}

\item{Catch}{A data frame of catch data, in pounds or in metric tons.}

\item{weight_length_estimates}{Dataframe of length-weight estimates with the
the following columns: sex, A, B. It is recommended to use to use
\code{nwfscSurvey::estimate_weight_length()} and to use survey data.}

\item{stratification.cols}{A vector of column names in \code{Pdata} that you want
to use as strata. These will match the way in which the catches are
transformed from long to wide prior to inputting them into this function.
If you leave this argument empty, then \code{Pdata} must already have a column
named \code{stratification}. The function will look in the column names of the
\code{Catch} data to determine the appropriate separator to use between columns
when pasting the words together, which is done using \link{apply} and \link{paste}.
Historically, it was mandatory to make this column yourself, but in 2021,
this input argument was added to reduce the number of extraneous calls that
were needed between functions. You can use as many levels of stratification
as you want except year because it is already included in the call to
\link[stats:aggregate]{stats::aggregate}.}

\item{Units}{The units of the \code{Catch} data frame, see
\code{measurements::conv_unit_options[["mass"]]} for options. Typical units
are metric tons (e.g., \code{"metric_ton"}) because that is the unit used
in Stock Synthesis, but expansions are done in pounds because fish weights
are in pounds. Thus, catches also need to be in pounds and will be
converted as such.}

\item{maxExp}{The maximum expansion factor (either a number or a quantile)
for building expansions. Typically, the default is 0.95. Set \code{maxExp = Inf} to see largest values.}

\item{Exp_WA}{A logical values specifying if the samples from Washington
should be expanded. The default is \code{FALSE}.}

\item{verbose}{A logical specifying if output should be written to the
screen or not. Good for testing and exploring your data but can be turned
off when output indicates information that you already know. The printing
of output to the screen does not affect any of the returned objects. The
default is to always print to the screen, i.e., \code{verbose = TRUE}.}

\item{savedir}{A file path to the directory where the results will be saved.
The default is NULL.}
}
\value{
A \code{data.frame} with expanded data up to the trip and total catch level.
}
\description{
Calculate the first- and second-stage expansions. The first-stage expansion
account for unsampled fish in the smallest measured unit.
Where, in PacFIN data, the smallest measured unit typically a trip
because that is what is available to the port or dockside sampler. Whereas,
in survey data the smallest measured unit is typically a tow. Tow would be
the smallest if we had samples from onboard observers rather than from
dockside samplers. The second-stage expansion expands data up to the state
or area catch level for that year and stratificiation.
Find the catch for each year and grouping in \code{Catch} and divide by the
pounds of fish that were collected for sampling for that same year and
grouping. Sampled biomass is stored in \code{All_Trips_Sampled_Lbs}, which is
the sum of Trip_Sampled_Lbs across sample numbers.
Catches were already stratified (i.e., summed by group placed in a column
for a given year or row). Catches are converted to pounds prior to dividing.
Thus, per-stratum Expansion_Factor_2 is the catch / sampled catch.
The total expansion is the product of the first and second stage expansion.
}
\details{
The workflow is to run this function [cleanPacFIN(),
which assures that all of the necessary columns are available and that the
data are in the correct units. This function then calls two helper functions,
\code{\link[=EF1_Numerator]{EF1_Numerator()}} and \code{\link[=EF1_Denominator]{EF1_Denominator()}} to calculate the weight of sampled fish and the weight of all fish of the respective species in the tow, respectively. Finally, the ratio of the two values is returned.
}
\section{Expansion}{

\itemize{
\item{Age data are expanded separately from lengths.}
\item{WA fish are generally only expanded using Expansion_Factor_2.}
\item{Expansions are the product of
Expansion_Factor_1 * Expansion_Factor_2.
}
\item{For age-at-length comps, set Final_Expansion_Factor to 1 because
each fish represents only itself.}
}
}

\examples{
\dontrun{
# Calculate the weight-length parameters for input to this function
bds_survey <- nwfscSurvey::pull_bio(
  common_name = "widow rockfish",
  survey = "NWFSC.Combo"
)
pars <- nwfscSurvey::estimate_weight_length(
  data = bds_survey,
  col_length = "length_cm",
  col_weight = "weight_kg",
  verbose = FALSE
)

expanded_comps <- get_pacfin_expansions(
  Pdata = bds_cleaned,
  Catch = catch_dataframe,
  weight_length_estimates = pars,
  Units = "MT",
  Comps = "LEN",
  maxExp = 0.95
)
}
}
\seealso{
\itemize{
\item \code{\link[=cleanPacFIN]{cleanPacFIN()}} (upstream)
\item \code{\link[nwfscSurvey:estimate_weight_length]{nwfscSurvey::estimate_weight_length()}} (upstream)
\item \code{\link[=getExpansion_1]{getExpansion_1()}} (contain within)
\item \code{\link[=getExpansion_2]{getExpansion_2()}} (contain within)
}
}
\author{
Chantel R. Wetzel
}
