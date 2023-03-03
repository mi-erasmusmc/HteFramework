dirs <- list.dirs(
  "~/Documents/Projects/framework/AceBeta9Outcomes/results",
  recursive = FALSE
)

dirs <- list(
  "/home/arekkas/Documents/Projects/framework/AceBeta9Outcomes/results/ccae_with_cvd_730_analysis",
  "/home/arekkas/Documents/Projects/framework/AceBeta9Outcomes/results/mdcd_with_cvd_730_analysis",
  "/home/arekkas/Documents/Projects/framework/AceBeta9Outcomes/results/ccae_without_cvd_730_analysis",
  "/home/arekkas/Documents/Projects/framework/AceBeta9Outcomes/results/mdcd_without_cvd_730_analysis",
  "/home/arekkas/Documents/Projects/framework/AceBeta9Outcomes/results/mdcr_without_cvd_730_analysis",
  "/home/arekkas/Documents/Projects/framework/AceBeta9Outcomes/results/mdcd_730_analysis",
  "/home/arekkas/Documents/Projects/framework/AceBeta9Outcomes/results/mdcr_730_analysis",
  "/home/arekkas/Documents/Projects/framework/AceBeta9Outcomes/results/ccae_730_analysis"
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

rseeViewer("~/Documents/Projects/framework/AceBeta9Outcomes/export/multipleRseeAnalyses/")
