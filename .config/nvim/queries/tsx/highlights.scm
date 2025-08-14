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

((jsx_opening_element
  name: (member_expression
    property: (property_identifier) @custom.jsx_subcomponent)))
((jsx_closing_element
  name: (member_expression
    property: (property_identifier) @custom.jsx_subcomponent)))
((jsx_self_closing_element
  name: (member_expression
    property: (property_identifier) @custom.jsx_subcomponent)))

((jsx_opening_element
  attribute: (jsx_attribute (property_identifier) @custom.jsx_prop)))
((jsx_self_closing_element
  attribute: (jsx_attribute (property_identifier) @custom.jsx_prop)))

((jsx_opening_element
   name: (identifier) @custom.jsx_component))
((jsx_closing_element
   name: (identifier) @custom.jsx_component))
((jsx_self_closing_element
   name: (identifier) @custom.jsx_component))
