;; Match default imports
((import_clause
  (identifier) @custom.imports))

;; Match named imports
((import_clause
  (named_imports
    (import_specifier
      (identifier) @custom.imports))))

;; Match aliases in named imports
((import_clause
  (named_imports
    (import_specifier
      name: (identifier) @custom.imports))))

;; Match the "type" keyword in a type alias declaration
((type_alias_declaration
  "type" @custom.type))
