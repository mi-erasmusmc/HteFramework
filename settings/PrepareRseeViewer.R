library(RiskStratifiedEstimation)

dirs <- list.dirs(
  "/path/to/results/results",
  recursive = FALSE
)

dirs <- list(
  "/path/to/results/ccae_with_cvd_730_analysis",
  "/path/to/results/mdcd_with_cvd_730_analysis",
  "/path/to/results/ccae_without_cvd_730_analysis",
  "/path/to/results/mdcd_without_cvd_730_analysis",
  "/path/to/results/mdcr_without_cvd_730_analysis",
  "/path/to/results/mdcd_730_analysis",
  "/path/to/results/mdcr_730_analysis",
  "/path/to/results/ccae_730_analysis"
)

analysisSettingsList <- list()
for (i in seq_along(dirs)) {
  settings <- readRDS(file.path(dirs[i], "settings.rds"))
  analysisSettingsList[[i]] <- settings$analysisSettings
}

prepareMultipleRseeViewer(
  analysisSettingsList = analysisSettingsList,
  saveDirectory = "export"
)

rseeViewer("/path/to/project/directory/export/multipleRseeAnalyses/")
