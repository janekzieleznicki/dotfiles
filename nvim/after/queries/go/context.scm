(function_declaration) @scope

(method_declaration) @scope

(type_declaration) @scope

(function_declaration
  name: (identifier) @context_name)

(method_declaration
  name: (field_identifier) @context_name)

(type_declaration
  (type_spec
    name: (type_identifier) @context_name))
