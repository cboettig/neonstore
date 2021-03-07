
#' Open NEON database connection pane in RStudio
#'
#' This function launches the RStudio "Connection" pane to interactively
#' explore the database.
#'
#' @return NULL
#' @export
#'
#' @examples
#' if (!is.null(getOption("connectionObserver"))) neon_pane()
neon_pane <- function() {
  observer <- getOption("connectionObserver")
  if (!is.null(observer) && interactive()) {
    observer$connectionOpened(
      type = "NEONDB",
      host = "neonstore",
      displayName = "NEON Tables",
      icon = system.file("img", "neon.png", package = "neonstore"),
      connectCode = "neonstore::neon_pane()",
      disconnect = neonstore::neon_disconnect,
      listObjectTypes = function() {
        list(
          table = list(contains = "data")
        )
      },
      listObjects = function(type = "datasets") {
        tbls <- DBI::dbListTables(neon_db())
        data.frame(
          name = tbls,
          type = rep("table", length(tbls)),
          stringsAsFactors = FALSE
        )
      },
      listColumns = function(table) {
        res <- DBI::dbGetQuery(neon_db(),
                               paste0("SELECT * FROM \"", table, "\" LIMIT 10"))
        data.frame(
          name = names(res), 
          type = vapply(res, function(x) class(x)[1], character(1)),
          stringsAsFactors = FALSE
        )
      },
      previewObject = function(rowLimit, table) {  #nolint
        DBI::dbGetQuery(neon_db(),
                        paste0("SELECT * FROM \"", table, "\" LIMIT ", rowLimit))
      },
      actions = list(
        Status = list(
          icon = system.file("img", "neon.png", package = "neonstore"),
          callback = neon_db_status
        ),
        SQL = list(
          icon = system.file("img", "edit-sql.png", package = "neonstore"),
          callback = sql_action
        )
      ),
      connectionObject = neon_db()
    )
  }
}

update_neon_pane <- function() {
  observer <- getOption("connectionObserver")
  if (!is.null(observer)) {
    observer$connectionUpdated("NEONDB", "neonstore", "")
  }
}

sql_action <- function() {
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      exists("documentNew", asNamespace("rstudioapi"))) {
    contents <- paste(
      "-- !preview conn=neonstore::neon_db()",
      "",
      "SELECT * FROM provenance LIMIT 10",
      "",
      sep = "\n"
    )
    
    rstudioapi::documentNew(
      text = contents, type = "sql",
      position = rstudioapi::document_position(2, 40),
      execute = FALSE
    )
  }
}

neon_db_status <- function () {
  con <- neon_db()
  inherits(con, "DBIConnection")
}


## Do not open the pane onAttach, wait for user to call neon_pane()
#.onAttach <- function(libname, pkgname) {  #nolint
#  if (interactive() && Sys.getenv("RSTUDIO") == "1"  && !in_chk()) {
#    tryCatch({neon_pane()}, error = function(e) NULL, finally = NULL)
#  }
#  if (interactive()) 
#    tryCatch(neon_db_status(),  error = function(e) NULL, finally = NULL)
#}


in_chk <- function() {
  any(
    grepl("check",
          sapply(sys.calls(), 
                 function(a) paste(deparse(a), collapse = "\n"))
    )
  )
}


