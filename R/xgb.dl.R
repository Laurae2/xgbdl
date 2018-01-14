#' Install xgboost from source
#'
#' Downloads and install xgboost from repository. Allows to customize the commit/branch used. Requires \code{git} and compiler \code{make} (or \code{mingw32-make} for MinGW) in \code{PATH} environment variable. Windows uses \code{\\\\} (backward slashes) while Linux uses \code{/} (forward slashes).
#' 
#' @param commit The commit / branch to use. Put \code{""} for master branch. Defaults to \code{"master"}.
#' @param compiler Applicable only to Windows. The compiler to use (either \code{"gcc"} for MinGW, \code{"Visual Studio 15 2017"} for Visual Studio). Defaults to \code{"gcc"}. Use \code{"Visual Studio 14 2015 Win64"} for the officially supported Visual Studio 2015.
#' @param repo The link to the repository. Defaults to \code{"https://github.com/dmlc/xgboost"}.
#' @param use_gpu Whether to install with GPU enabled or not. Defaults to \code{FALSE}. Not supported on Linux, do it by yourself!
#' 
#' @return A logical describing whether the xgboost package was installed or not (\code{TRUE} if installed, \code{FALSE} if installation failed AND you did not have the package before).
#' 
#' @examples
#' \dontrun{
#' # Install using Visual Studio
#' # (Download: http://landinghub.visualstudio.com/visual-cpp-build-tools)
#' xgb.dl(commit = "master",
#'        compiler = "Visual Studio 15 2017 Win64",
#'        repo = "https://github.com/dmlc/xgboost")
#' 
#' # Install using Rtools MinGW or use Linux compilation
#' xgb.dl(commit = "master",
#'        compiler = "gcc",
#'        repo = "https://github.com/dmlc/xgboost")
#' 
#' # Install using Visual Studio with GPU support
#' xgb.dl(commit = "master",
#'        compiler = "Visual Studio 15 2017 Win64",
#'        repo = "https://github.com/dmlc/xgboost",
#'        use_gpu = TRUE)
#' 
#' # Test package
#' library(xgboost)
#' data(agaricus.train, package = "xgboost")
#' data(agaricus.test, package = "xgboost")
#' 
#' dtrain <- xgb.DMatrix(agaricus.train$data, label = agaricus.train$label)
#' dtest <- xgb.DMatrix(agaricus.test$data, label = agaricus.test$label)
#' watchlist <- list(train = dtrain, eval = dtest)
#' 
#' param <- list(max_depth = 2, eta = 1, silent = 1, nthread = 2, 
#'               objective = "binary:logistic", eval_metric = "auc")
#' bst <- xgb.train(param, dtrain, nrounds = 2, watchlist)
#' }
#' 
#' @export

xgb.dl <- function(commit = "master",
                   compiler = "gcc",
                   repo = "https://github.com/dmlc/xgboost",
                   use_gpu = FALSE) {
  
  # Generates temporary dir
  xgb_git_dir <- tempdir()
  
  # Check if it is Windows, because it create most issues
  if (.Platform$OS.type == "windows") {
    
    # Create temp file
    xgb_git_file <- file.path(xgb_git_dir, "temp.bat", fsep = "\\")
    
    # Delete (old) temp xgboost folder
    unlink(paste0(file.path(xgb_git_dir, "xgboost", fsep = "\\")), recursive = TRUE, force = TRUE)
    
    # Use git to fetch data from repository
    cat(paste0("c:", "\n"), file = xgb_git_file)
    cat(paste0("cd ", xgb_git_dir, "\n"), file = xgb_git_file, append = TRUE)
    cat(paste0("git clone --recursive ", repo, "\n"), file = xgb_git_file, append = TRUE)
    cat(paste0("cd xgboost", "\n"), file = xgb_git_file, append = TRUE)
    
    # Checkout specific commit if needed
    if (commit != "") {
      cat(paste0("git checkout ", commit, "\n"), file = xgb_git_file, append = TRUE)
    }
    
    # Check if compilation must be done using MinGW/gcc (default) or Visual Studio
    if (compiler == "gcc") {
      
      cat(paste0("cd R-package", "\n"), file = xgb_git_file, append = TRUE)
      cat("R CMD INSTALL .\n", file = xgb_git_file, append = TRUE)
      
    } else {
      
      cat(paste0("mkdir build && cd build", "\n"), file = xgb_git_file, append = TRUE)
      cat(paste0("cmake .. -G\"", compiler, "\" ", ifelse(use_gpu == TRUE, "-DUSE_CUDA=ON", ""), " -DR_LIB=ON", "\n"), file = xgb_git_file, append = TRUE)
      cat("cmake --build . --target install --config Release\n", file = xgb_git_file, append = TRUE)
      
    }
    
    # Do actions
    system(xgb_git_file)
    
    # Get rid of the created temporary folder
    unlink(paste0(file.path(xgb_git_dir, "xgboost", fsep = "\\")), recursive = TRUE, force = TRUE)
    
  } else {
    
    # Create temp file
    xgb_git_file <- file.path(xgb_git_dir, "temp.sh")
    
    # Delete (old) temp xgboost folder
    unlink(paste0(file.path(xgb_git_dir, "xgboost")), recursive = TRUE, force = TRUE)
    
    # Use git to fetch data from repository
    cat(paste0("cd ", xgb_git_dir, "\n"), file = xgb_git_file)
    cat(paste0("git clone --recursive ", repo, "\n"), file = xgb_git_file, append = TRUE)
    cat(paste0("cd xgboost", "\n"), file = xgb_git_file, append = TRUE)
    
    # Checkout specific commit if needed
    if (commit != "") {
      cat(paste0("git checkout ", commit, "\n"), file = xgb_git_file, append = TRUE)
    }
    
    # Compile
    
    cat(paste0("mkdir build && cd build", "\n"), file = xgb_git_file, append = TRUE)
    cat(paste0("cmake .. ", ifelse(use_gpu == TRUE, "-DUSE_CUDA=ON", ""), " -DR_LIB=ON", "\n"), file = xgb_git_file, append = TRUE)
    cat(paste0("make install -j", "\n"), file = xgb_git_file, append = TRUE)
    
    # Do actions
    system(xgb_git_file)
    
    # Get rid of the created temporary folder
    unlink(paste0(file.path(xgb_git_dir, "xgboost")), recursive = TRUE, force = TRUE)
    
  }
  
  return(nzchar(system.file(package = "xgboost")))
  
}
