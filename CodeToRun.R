
# install.packages("renv") # if not already installed, install renv from CRAN
renv::activate()
renv::restore() # this should prompt you to install the various packages required for the study

# packages -----
# load the below packages 
# you should have them all available, with the required version, after
# having run renv::restore above
library(DatabaseConnector)
library(CohortDiagnostics)
library(CirceR)
library(CohortGenerator)
library(here)
library(stringr)

# database metadata and connection details -----
# The name/ acronym for the database
db.name<-"..."

# database connection details
server<-"..."
user<-"..."
password<- "..."
port<-"..."
host<-"..."

# driver for DatabaseConnector
downloadJdbcDrivers("...", here()) # if you already have this you can omit and change pathToDriver below
connectionDetails <- createConnectionDetails(dbms = "...",
                                             server =server,
                                             user = user,
                                             password = password,
                                             port = port ,
                                             pathToDriver = here())

# sql dialect used with the OHDSI SqlRender package
targetDialect <-"..." 
# schema that contains the OMOP CDM with patient-level data
cdm_database_schema<-"..."
# schema that contains the vocabularie
vocabulary_database_schema<-"..."
# schema where a results table will be created 
results_database_schema<-"..."

# stem for tables to be created in your results schema for this analysis
# You can keep the above names or change them
# Note, any existing tables in your results schema with the same name will be overwritten
cohortTableStem<-"..."

# Run analysis ----
source(here("RunAnalysis.R"))


# Review results -----
CohortDiagnostics::preMergeDiagnosticsFiles(dataFolder = here("Results"))
#CohortDiagnostics::launchDiagnosticsExplorer(dataFolder = here("Results"))

#Make results compatable ---- DATABASE DO NOT RUN
# This runs to make all cohort numbers consistent as some data partners can only run certain conditions
# naming dataframe (namingdf) is a dataframe of 2 columns containing the cohort_ID and the cohort name for the current
# cohort diagnostics outputs you want to convert 
# cohort_id <- c(seq(1:9))
# cohort_name <- c("MalignantBreastCancer"    ,
#                  "MalignantColorectalCancer"   ,
#                  "MalignantColorectalCancerBROAD" ,
#                  "MalignantHeadNeckCancer"     ,
#                  "MalignantLiverCancer"  ,
#                  "MalignantLungCancer"        ,
#                  "MalignantPancreaticCancer" ,
#                  "MalignantProstateCancer"   ,
#                  "MalignantStomachCancer"
# )
# 
# namingdf <- as.data.frame(cbind(cohort_id, cohort_name)) %>%
#   mutate(cohort_id = as.numeric(cohort_id))
# 
# aligningresults <-
#   function(inputFolder,
#            outputFolder,
#            namingdf) {
# 
#     tempFolder <- tempdir()
#     unzipFolder <- tempfile(tmpdir = tempFolder)
#     dir.create(path = unzipFolder, recursive = TRUE)
#     on.exit(unlink(unzipFolder, recursive = TRUE), add = TRUE)
# 
#     zipFiles <-
#       list.files(
#         path = inputFolder,
#         pattern = ".zip",
#         full.names = TRUE,
#         recursive = TRUE,
#         include.dirs = TRUE
#       )
# 
#     if (length(zipFiles) == 0) {
#       stop("Did not find zipped file in inputFolder location")
#     }
# 
#     resultsDataModel <-
#       CohortDiagnostics::getResultsDataModelSpecifications()
#     tablesInResultsDataModel <- resultsDataModel %>%
#       dplyr::select(.data$tableName) %>%
#       dplyr::distinct() %>%
#       dplyr::arrange() %>%
#       dplyr::pull(.data$tableName)
# 
# 
#     for (i in (1:length(zipFiles))) {
#       ParallelLogger::logInfo("Unzipping ", basename(zipFiles[[i]]))
#       exportDirectory <-
#         file.path(unzipFolder, i, tools::file_path_sans_ext(basename(zipFiles[[i]])))
#       utils::unzip(zipfile = zipFiles[[i]],
#                    junkpaths = FALSE,
#                    exdir = exportDirectory)
#       listOfFilesInZippedFolder <-
#         list.files(path = exportDirectory, pattern = ".csv")
# 
#       for (j in (1:length(tablesInResultsDataModel))) {
#         if (paste0(tablesInResultsDataModel[[j]], ".csv") %in% listOfFilesInZippedFolder) {
#           dataFromZip <-
#             readr::read_csv(file = file.path(
#               exportDirectory,
#               paste0(tablesInResultsDataModel[[j]], ".csv")
#             ),
#             col_types = readr::cols()) # if csv file is in list of zipped files then read it
# 
#           if ("cohort_id" %in% colnames(dataFromZip)) {
# 
#             if(paste0(tablesInResultsDataModel[[j]], ".csv") == "cohort.csv"){
# 
#               dataFromZip <- dataFromZip %>%
#                 dplyr::inner_join(x = ., y = namingdf, by = c("cohort_id"))
# 
#               dataFromZip <- dataFromZip %>%
#                 dplyr::mutate(cohort_id = case_when(cohort_name.y == "MalignantBreastCancer" ~ 1,
#                                                     cohort_name.y == "MalignantColorectalCancer"~ 2,
#                                                     cohort_name.y == "MalignantColorectalCancerBROAD"~ 3,
#                                                     cohort_name.y == "MalignantColorectalCancerRead"~4,
#                                                     cohort_name.y == "MalignantHeadNeckCancer"~ 5,
#                                                     cohort_name.y == "MalignantLiverBileDuctCancer"~ 6,
#                                                     cohort_name.y == "MalignantLiverCancer"~ 7,
#                                                     cohort_name.y == "MalignantLungCancer"~ 8,
#                                                     cohort_name.y == "MalignantPancreaticCancer"~ 9,
#                                                     cohort_name.y == "MalignantProstateCancer"~ 10,
#                                                     cohort_name.y == "MalignantStomachCancer"~ 11 )) %>%
#                 dplyr::select(-(cohort_name.y)) %>%
#                 dplyr::rename(cohort_name = cohort_name.x)
# 
#             }
# 
#             if(paste0(tablesInResultsDataModel[[j]], ".csv") != "cohort.csv"){
#               dataFromZip <- dataFromZip %>%
#                 dplyr::inner_join(x = ., y = namingdf, by = c("cohort_id"))
# 
#               dataFromZip <- dataFromZip %>%
#                 dplyr::mutate(cohort_id = case_when(cohort_name == "MalignantBreastCancer" ~ 1,
#                                                     cohort_name == "MalignantColorectalCancer"~ 2,
#                                                     cohort_name == "MalignantColorectalCancerBROAD"~ 3,
#                                                     cohort_name == "MalignantColorectalCancerRead"~4,
#                                                     cohort_name == "MalignantHeadNeckCancer"~ 5,
#                                                     cohort_name == "MalignantLiverBileDuctCancer"~ 6,
#                                                     cohort_name == "MalignantLiverCancer"~ 7,
#                                                     cohort_name == "MalignantLungCancer"~ 8,
#                                                     cohort_name == "MalignantPancreaticCancer"~ 9,
#                                                     cohort_name == "MalignantProstateCancer"~ 10,
#                                                     cohort_name == "MalignantStomachCancer"~ 11 )) %>%
#                 dplyr::select(-(cohort_name))
# 
#             }
# 
#           }
# 
#           if ("target_cohort_id" %in% colnames(dataFromZip)) {
# 
#             dataFromZip <- dataFromZip %>%
#               dplyr::inner_join(x = ., y = namingdf, by = c("target_cohort_id" = "cohort_id"))
# 
#             dataFromZip <- dataFromZip %>%
#               dplyr::mutate(target_cohort_id = case_when(cohort_name == "MalignantBreastCancer" ~ 1,
#                                                          cohort_name == "MalignantColorectalCancer"~ 2,
#                                                          cohort_name == "MalignantColorectalCancerBROAD"~ 3,
#                                                          cohort_name == "MalignantColorectalCancerRead"~4,
#                                                          cohort_name == "MalignantHeadNeckCancer"~ 5,
#                                                          cohort_name == "MalignantLiverBileDuctCancer"~ 6,
#                                                          cohort_name == "MalignantLiverCancer"~ 7,
#                                                          cohort_name == "MalignantLungCancer"~ 8,
#                                                          cohort_name == "MalignantPancreaticCancer"~ 9,
#                                                          cohort_name == "MalignantProstateCancer"~ 10,
#                                                          cohort_name == "MalignantStomachCancer"~ 11 )) %>%
#               dplyr::select(-(cohort_name))
# 
#             dataFromZip <- dataFromZip %>%
#               dplyr::inner_join(x = ., y = namingdf, by = c("comparator_cohort_id" = "cohort_id"))
# 
#             dataFromZip <- dataFromZip %>%
#               dplyr::mutate(comparator_cohort_id = case_when(cohort_name == "MalignantBreastCancer" ~ 1,
#                                                              cohort_name == "MalignantColorectalCancer"~ 2,
#                                                              cohort_name == "MalignantColorectalCancerBROAD"~ 3,
#                                                              cohort_name == "MalignantColorectalCancerRead"~4,
#                                                              cohort_name == "MalignantHeadNeckCancer"~ 5,
#                                                              cohort_name == "MalignantLiverBileDuctCancer"~ 6,
#                                                              cohort_name == "MalignantLiverCancer"~ 7,
#                                                              cohort_name == "MalignantLungCancer"~ 8,
#                                                              cohort_name == "MalignantPancreaticCancer"~ 9,
#                                                              cohort_name == "MalignantProstateCancer"~ 10,
#                                                              cohort_name == "MalignantStomachCancer"~ 11 )) %>%
#               dplyr::select(-(cohort_name))
# 
#           }
# 
#           readr::write_excel_csv(
#             x = dataFromZip,
#             file = file.path(
#               exportDirectory,
#               paste0(tablesInResultsDataModel[[j]], ".csv")
#             ),
#             na = "",
#             quote = "all",
#             append = FALSE
#           )
#         }
#       }
# 
#       dir.create(path = outputFolder,
#                  showWarnings = FALSE,
#                  recursive = TRUE)
#       DatabaseConnector::createZipFile(
#         zipFile = file.path(outputFolder, basename(zipFiles[[i]])),
#         files = list.files(
#           path = exportDirectory,
#           pattern = ".csv",
#           full.names = TRUE,
#           include.dirs = TRUE
#         ),
#         rootFolder = exportDirectory
#       )
#     }
# 
#   }
# 
# 
# aligningresults(inputFolder = here("Results", "ToAlign" ),
#                 outputFolder = here("Results", "ToFilter"),
#                 namingdf = namingdf
# 
# )
# 
# #remove cohorts we do not need
# subsetResultsZip <-
#   function(inputFolder,
#            outputFolder,
#            cohortIds) {
# 
#     checkmate::assertIntegerish(
#       x = cohortIds,
#       any.missing = FALSE,
#       min.len = 1,
#       null.ok = FALSE
#     )
# 
#     tempFolder <- tempdir()
#     unzipFolder <- tempfile(tmpdir = tempFolder)
#     dir.create(path = unzipFolder, recursive = TRUE)
#     on.exit(unlink(unzipFolder, recursive = TRUE), add = TRUE)
# 
#     zipFiles <-
#       list.files(
#         path = inputFolder,
#         pattern = ".zip",
#         full.names = TRUE,
#         recursive = TRUE,
#         include.dirs = TRUE
#       )
# 
#     if (length(zipFiles) == 0) {
#       stop("Did not find zipped file in inputFolder location")
#     }
# 
#     resultsDataModel <-
#       CohortDiagnostics::getResultsDataModelSpecifications()
#     tablesInResultsDataModel <- resultsDataModel %>%
#       dplyr::select(.data$tableName) %>%
#       dplyr::distinct() %>%
#       dplyr::arrange() %>%
#       dplyr::pull(.data$tableName)
# 
#     for (i in (1:length(zipFiles))) {
#       ParallelLogger::logInfo("Unzipping ", basename(zipFiles[[i]]))
#       exportDirectory <-
#         file.path(unzipFolder, i, tools::file_path_sans_ext(basename(zipFiles[[i]])))
#       utils::unzip(zipfile = zipFiles[[i]],
#                    junkpaths = FALSE,
#                    exdir = exportDirectory)
#       listOfFilesInZippedFolder <-
#         list.files(path = exportDirectory, pattern = ".csv")
# 
#       for (j in (1:length(tablesInResultsDataModel))) {
#         if (paste0(tablesInResultsDataModel[[j]], ".csv") %in% listOfFilesInZippedFolder) {
#           dataFromZip <-
#             readr::read_csv(file = file.path(
#               exportDirectory,
#               paste0(tablesInResultsDataModel[[j]], ".csv")
#             ),
#             col_types = readr::cols())
# 
#           if ("cohort_id" %in% colnames(dataFromZip)) {
#             dataFromZip <- dataFromZip %>%
#               dplyr::filter(.data$cohort_id %in% cohortIds)
#           }
# 
# 
#           if ("target_cohort_id" %in% colnames(dataFromZip)) {
#             dataFromZip <- dataFromZip %>%
#               dplyr::filter(.data$target_cohort_id %in% cohortIds) %>%
#               dplyr::filter(.data$comparator_cohort_id %in% cohortIds)
# 
#           }
# 
# 
# 
#           readr::write_excel_csv(
#             x = dataFromZip,
#             file = file.path(
#               exportDirectory,
#               paste0(tablesInResultsDataModel[[j]], ".csv")
#             ),
#             na = "",
#             quote = "all",
#             append = FALSE
#           )
#         }
#       }
# 
#       dir.create(path = outputFolder,
#                  showWarnings = FALSE,
#                  recursive = TRUE)
#       DatabaseConnector::createZipFile(
#         zipFile = file.path(outputFolder, basename(zipFiles[[i]])),
#         files = list.files(
#           path = exportDirectory,
#           pattern = ".csv",
#           full.names = TRUE,
#           include.dirs = TRUE
#         ),
#         rootFolder = exportDirectory
#       )
#     }
#   }
# 
# # only includes the 3 cancers for OPTIMA
# subsetResultsZip(inputFolder = here("Results", "ToFilter"),
#                  outputFolder = here("Results", "ForShiny"),
#                  cohortIds = c(1,8,10)
# )
# 
# 
# # Review results -----
# CohortDiagnostics::preMergeDiagnosticsFiles(dataFolder = here("Results", "ForShiny"))
# CohortDiagnostics::launchDiagnosticsExplorer(dataFolder = here("Results", "ForShiny"))
# 
# 
# subsetResultsZip(inputFolder = here("Results", "ToFilter"),
#                  outputFolder = here("Results", "ForShinyFull"),
#                  cohortIds = c(1,2,5,7,8,9,10,11)
# )
# 
# CohortDiagnostics::preMergeDiagnosticsFiles(dataFolder = here("Results", "ForShinyFull"))
# CohortDiagnostics::launchDiagnosticsExplorer(dataFolder = here("Results", "ForShinyFull"))
# 


