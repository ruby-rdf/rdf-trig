# This file is automatically generated by /Users/gregg/.rvm/gems/ruby-1.9.3-p392/gems/ebnf-0.3.0/bin/ebnf
# BRANCH derived from etc/trig.bnf
module RDF::TriG::Meta
  START = :trigDoc

  BRANCH = {
    :BlankNode => {
      :ANON => [:ANON],
      :BLANK_NODE_LABEL => [:BLANK_NODE_LABEL],
    },
    :BooleanLiteral => {
      "false" => ["false"],
      "true" => ["true"],
    },
    :NumericLiteral => {
      :DECIMAL => [:DECIMAL],
      :DOUBLE => [:DOUBLE],
      :INTEGER => [:INTEGER],
    },
    :PrefixedName => {
      :PNAME_LN => [:PNAME_LN],
      :PNAME_NS => [:PNAME_NS],
    },
    :RDFLiteral => {
      :STRING_LITERAL_LONG_QUOTE => [:String, :_RDFLiteral_1],
      :STRING_LITERAL_LONG_SINGLE_QUOTE => [:String, :_RDFLiteral_1],
      :STRING_LITERAL_QUOTE => [:String, :_RDFLiteral_1],
      :STRING_LITERAL_SINGLE_QUOTE => [:String, :_RDFLiteral_1],
    },
    :_RDFLiteral_1 => {
      "(" => [],
      ")" => [],
      "," => [],
      "." => [],
      ";" => [],
      :ANON => [],
      :BLANK_NODE_LABEL => [],
      :DECIMAL => [],
      :DOUBLE => [],
      :INTEGER => [],
      :IRIREF => [],
      :LANGTAG => [:_RDFLiteral_2],
      :PNAME_LN => [],
      :PNAME_NS => [],
      :STRING_LITERAL_LONG_QUOTE => [],
      :STRING_LITERAL_LONG_SINGLE_QUOTE => [],
      :STRING_LITERAL_QUOTE => [],
      :STRING_LITERAL_SINGLE_QUOTE => [],
      "[" => [],
      "]" => [],
      "^^" => [:_RDFLiteral_2],
      "false" => [],
      "true" => [],
    },
    :_RDFLiteral_2 => {
      :LANGTAG => [:LANGTAG],
      "^^" => [:_RDFLiteral_3],
    },
    :_RDFLiteral_3 => {
      "^^" => ["^^", :iri],
    },
    :String => {
      :STRING_LITERAL_LONG_QUOTE => [:STRING_LITERAL_LONG_QUOTE],
      :STRING_LITERAL_LONG_SINGLE_QUOTE => [:STRING_LITERAL_LONG_SINGLE_QUOTE],
      :STRING_LITERAL_QUOTE => [:STRING_LITERAL_QUOTE],
      :STRING_LITERAL_SINGLE_QUOTE => [:STRING_LITERAL_SINGLE_QUOTE],
    },
    :base => {
      :BASE => [:BASE, :IRIREF, :_base_1],
    },
    :_base_1 => {
      "." => ["."],
      :BASE => [],
      :IRIREF => [],
      :PNAME_LN => [],
      :PNAME_NS => [],
      :PREFIX => [],
      "{" => [],
    },
    :blankNodePropertyList => {
      "[" => ["[", :predicateObjectList, "]"],
    },
    :collection => {
      "(" => ["(", :_collection_1, ")"],
    },
    :_collection_1 => {
      "(" => [:_collection_2],
      ")" => [],
      :ANON => [:_collection_2],
      :BLANK_NODE_LABEL => [:_collection_2],
      :DECIMAL => [:_collection_2],
      :DOUBLE => [:_collection_2],
      :INTEGER => [:_collection_2],
      :IRIREF => [:_collection_2],
      :PNAME_LN => [:_collection_2],
      :PNAME_NS => [:_collection_2],
      :STRING_LITERAL_LONG_QUOTE => [:_collection_2],
      :STRING_LITERAL_LONG_SINGLE_QUOTE => [:_collection_2],
      :STRING_LITERAL_QUOTE => [:_collection_2],
      :STRING_LITERAL_SINGLE_QUOTE => [:_collection_2],
      "[" => [:_collection_2],
      "false" => [:_collection_2],
      "true" => [:_collection_2],
    },
    :_collection_2 => {
      "(" => [:object, :_collection_1],
      :ANON => [:object, :_collection_1],
      :BLANK_NODE_LABEL => [:object, :_collection_1],
      :DECIMAL => [:object, :_collection_1],
      :DOUBLE => [:object, :_collection_1],
      :INTEGER => [:object, :_collection_1],
      :IRIREF => [:object, :_collection_1],
      :PNAME_LN => [:object, :_collection_1],
      :PNAME_NS => [:object, :_collection_1],
      :STRING_LITERAL_LONG_QUOTE => [:object, :_collection_1],
      :STRING_LITERAL_LONG_SINGLE_QUOTE => [:object, :_collection_1],
      :STRING_LITERAL_QUOTE => [:object, :_collection_1],
      :STRING_LITERAL_SINGLE_QUOTE => [:object, :_collection_1],
      "[" => [:object, :_collection_1],
      "false" => [:object, :_collection_1],
      "true" => [:object, :_collection_1],
    },
    :directive => {
      :BASE => [:base],
      :PREFIX => [:prefixID],
    },
    :graph => {
      :IRIREF => [:_graph_1],
      :PNAME_LN => [:_graph_1],
      :PNAME_NS => [:_graph_1],
      "{" => [:_graph_2],
    },
    :graphIri => {
      :IRIREF => [:iri],
      :PNAME_LN => [:iri],
      :PNAME_NS => [:iri],
    },
    :_graph_1 => {
      :IRIREF => [:graphIri, "{", :_graph_3, "}"],
      :PNAME_LN => [:graphIri, "{", :_graph_3, "}"],
      :PNAME_NS => [:graphIri, "{", :_graph_3, "}"],
    },
    :_graph_2 => {
      "{" => ["{", :_graph_6, "}"],
    },
    :_graph_3 => {
      "(" => [:_graph_5],
      :ANON => [:_graph_5],
      :BLANK_NODE_LABEL => [:_graph_5],
      :IRIREF => [:_graph_5],
      :PNAME_LN => [:_graph_5],
      :PNAME_NS => [:_graph_5],
      "[" => [:_graph_5],
      "}" => [],
    },
    :_graph_4 => {
      "(" => [:triples, "."],
      :ANON => [:triples, "."],
      :BLANK_NODE_LABEL => [:triples, "."],
      :IRIREF => [:triples, "."],
      :PNAME_LN => [:triples, "."],
      :PNAME_NS => [:triples, "."],
      "[" => [:triples, "."],
    },
    :_graph_5 => {
      "(" => [:_graph_4, :_graph_3],
      :ANON => [:_graph_4, :_graph_3],
      :BLANK_NODE_LABEL => [:_graph_4, :_graph_3],
      :IRIREF => [:_graph_4, :_graph_3],
      :PNAME_LN => [:_graph_4, :_graph_3],
      :PNAME_NS => [:_graph_4, :_graph_3],
      "[" => [:_graph_4, :_graph_3],
    },
    :_graph_6 => {
      "(" => [:_graph_8],
      :ANON => [:_graph_8],
      :BLANK_NODE_LABEL => [:_graph_8],
      :IRIREF => [:_graph_8],
      :PNAME_LN => [:_graph_8],
      :PNAME_NS => [:_graph_8],
      "[" => [:_graph_8],
      "}" => [],
    },
    :_graph_7 => {
      "(" => [:triples, "."],
      :ANON => [:triples, "."],
      :BLANK_NODE_LABEL => [:triples, "."],
      :IRIREF => [:triples, "."],
      :PNAME_LN => [:triples, "."],
      :PNAME_NS => [:triples, "."],
      "[" => [:triples, "."],
    },
    :_graph_8 => {
      "(" => [:_graph_7, :_graph_6],
      :ANON => [:_graph_7, :_graph_6],
      :BLANK_NODE_LABEL => [:_graph_7, :_graph_6],
      :IRIREF => [:_graph_7, :_graph_6],
      :PNAME_LN => [:_graph_7, :_graph_6],
      :PNAME_NS => [:_graph_7, :_graph_6],
      "[" => [:_graph_7, :_graph_6],
    },
    :graph_statement => {
      :BASE => [:directive],
      :IRIREF => [:graph],
      :PNAME_LN => [:graph],
      :PNAME_NS => [:graph],
      :PREFIX => [:directive],
      "{" => [:graph],
    },
    :iri => {
      :IRIREF => [:IRIREF],
      :PNAME_LN => [:PrefixedName],
      :PNAME_NS => [:PrefixedName],
    },
    :literal => {
      :DECIMAL => [:NumericLiteral],
      :DOUBLE => [:NumericLiteral],
      :INTEGER => [:NumericLiteral],
      :STRING_LITERAL_LONG_QUOTE => [:RDFLiteral],
      :STRING_LITERAL_LONG_SINGLE_QUOTE => [:RDFLiteral],
      :STRING_LITERAL_QUOTE => [:RDFLiteral],
      :STRING_LITERAL_SINGLE_QUOTE => [:RDFLiteral],
      "false" => [:BooleanLiteral],
      "true" => [:BooleanLiteral],
    },
    :object => {
      "(" => [:collection],
      :ANON => [:BlankNode],
      :BLANK_NODE_LABEL => [:BlankNode],
      :DECIMAL => [:literal],
      :DOUBLE => [:literal],
      :INTEGER => [:literal],
      :IRIREF => [:iri],
      :PNAME_LN => [:iri],
      :PNAME_NS => [:iri],
      :STRING_LITERAL_LONG_QUOTE => [:literal],
      :STRING_LITERAL_LONG_SINGLE_QUOTE => [:literal],
      :STRING_LITERAL_QUOTE => [:literal],
      :STRING_LITERAL_SINGLE_QUOTE => [:literal],
      "[" => [:blankNodePropertyList],
      "false" => [:literal],
      "true" => [:literal],
    },
    :objectList => {
      "(" => [:object, :_objectList_1],
      :ANON => [:object, :_objectList_1],
      :BLANK_NODE_LABEL => [:object, :_objectList_1],
      :DECIMAL => [:object, :_objectList_1],
      :DOUBLE => [:object, :_objectList_1],
      :INTEGER => [:object, :_objectList_1],
      :IRIREF => [:object, :_objectList_1],
      :PNAME_LN => [:object, :_objectList_1],
      :PNAME_NS => [:object, :_objectList_1],
      :STRING_LITERAL_LONG_QUOTE => [:object, :_objectList_1],
      :STRING_LITERAL_LONG_SINGLE_QUOTE => [:object, :_objectList_1],
      :STRING_LITERAL_QUOTE => [:object, :_objectList_1],
      :STRING_LITERAL_SINGLE_QUOTE => [:object, :_objectList_1],
      "[" => [:object, :_objectList_1],
      "false" => [:object, :_objectList_1],
      "true" => [:object, :_objectList_1],
    },
    :_objectList_1 => {
      "," => [:_objectList_3],
      "." => [],
      ";" => [],
      "]" => [],
    },
    :_objectList_2 => {
      "," => [",", :object],
    },
    :_objectList_3 => {
      "," => [:_objectList_2, :_objectList_1],
    },
    :predicate => {
      :IRIREF => [:iri],
      :PNAME_LN => [:iri],
      :PNAME_NS => [:iri],
    },
    :predicateObjectList => {
      "A" => [:verb, :objectList, :_predicateObjectList_1],
      :IRIREF => [:verb, :objectList, :_predicateObjectList_1],
      :PNAME_LN => [:verb, :objectList, :_predicateObjectList_1],
      :PNAME_NS => [:verb, :objectList, :_predicateObjectList_1],
      "a" => [:verb, :objectList, :_predicateObjectList_1],
    },
    :_predicateObjectList_1 => {
      "." => [],
      ";" => [:_predicateObjectList_3],
      "]" => [],
    },
    :_predicateObjectList_2 => {
      ";" => [";", :_predicateObjectList_4],
    },
    :_predicateObjectList_3 => {
      ";" => [:_predicateObjectList_2, :_predicateObjectList_1],
    },
    :_predicateObjectList_4 => {
      "." => [],
      ";" => [],
      "A" => [:_predicateObjectList_5],
      :IRIREF => [:_predicateObjectList_5],
      :PNAME_LN => [:_predicateObjectList_5],
      :PNAME_NS => [:_predicateObjectList_5],
      "]" => [],
      "a" => [:_predicateObjectList_5],
    },
    :_predicateObjectList_5 => {
      "A" => [:verb, :objectList],
      :IRIREF => [:verb, :objectList],
      :PNAME_LN => [:verb, :objectList],
      :PNAME_NS => [:verb, :objectList],
      "a" => [:verb, :objectList],
    },
    :prefixID => {
      :PREFIX => [:PREFIX, :PNAME_NS, :IRIREF, :_prefixID_1],
    },
    :_prefixID_1 => {
      "." => ["."],
      :BASE => [],
      :IRIREF => [],
      :PNAME_LN => [],
      :PNAME_NS => [],
      :PREFIX => [],
      "{" => [],
    },
    :subject => {
      "(" => [:collection],
      :ANON => [:BlankNode],
      :BLANK_NODE_LABEL => [:BlankNode],
      :IRIREF => [:iri],
      :PNAME_LN => [:iri],
      :PNAME_NS => [:iri],
    },
    :trigDoc => {
      :BASE => [:_trigDoc_1],
      :IRIREF => [:_trigDoc_1],
      :PNAME_LN => [:_trigDoc_1],
      :PNAME_NS => [:_trigDoc_1],
      :PREFIX => [:_trigDoc_1],
      "{" => [:_trigDoc_1],
    },
    :_trigDoc_1 => {
      :BASE => [:graph_statement, :trigDoc],
      :IRIREF => [:graph_statement, :trigDoc],
      :PNAME_LN => [:graph_statement, :trigDoc],
      :PNAME_NS => [:graph_statement, :trigDoc],
      :PREFIX => [:graph_statement, :trigDoc],
      "{" => [:graph_statement, :trigDoc],
    },
    :triples => {
      "(" => [:_triples_1],
      :ANON => [:_triples_1],
      :BLANK_NODE_LABEL => [:_triples_1],
      :IRIREF => [:_triples_1],
      :PNAME_LN => [:_triples_1],
      :PNAME_NS => [:_triples_1],
      "[" => [:_triples_2],
    },
    :_triples_1 => {
      "(" => [:subject, :predicateObjectList],
      :ANON => [:subject, :predicateObjectList],
      :BLANK_NODE_LABEL => [:subject, :predicateObjectList],
      :IRIREF => [:subject, :predicateObjectList],
      :PNAME_LN => [:subject, :predicateObjectList],
      :PNAME_NS => [:subject, :predicateObjectList],
    },
    :_triples_2 => {
      "[" => [:blankNodePropertyList, :_triples_3],
    },
    :_triples_3 => {
      "." => [],
      "A" => [:predicateObjectList],
      :IRIREF => [:predicateObjectList],
      :PNAME_LN => [:predicateObjectList],
      :PNAME_NS => [:predicateObjectList],
      "a" => [:predicateObjectList],
    },
    :verb => {
      "A" => ["A"],
      :IRIREF => [:predicate],
      :PNAME_LN => [:predicate],
      :PNAME_NS => [:predicate],
      "a" => ["a"],
    },
  }.freeze
  TERMINALS = [
    "(",
    ")",
    ",",
    ".",
    ";",
    "A",
    :ANON,
    :BASE,
    :BLANK_NODE_LABEL,
    :DECIMAL,
    :DOUBLE,
    :INTEGER,
    :IRIREF,
    :LANGTAG,
    :PNAME_LN,
    :PNAME_NS,
    :PREFIX,
    :STRING_LITERAL_LONG_QUOTE,
    :STRING_LITERAL_LONG_SINGLE_QUOTE,
    :STRING_LITERAL_QUOTE,
    :STRING_LITERAL_SINGLE_QUOTE,
    "[",
    "]",
    "^^",
    "a",
    "false",
    "true",
    "{",
    "}"
  ].freeze
  FIRST = {
    :BlankNode => [
      :BLANK_NODE_LABEL,
      :ANON],
    :BooleanLiteral => [
      "true",
      "false"],
    :NumericLiteral => [
      :INTEGER,
      :DECIMAL,
      :DOUBLE],
    :PrefixedName => [
      :PNAME_LN,
      :PNAME_NS],
    :RDFLiteral => [
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_RDFLiteral_1 => [
      :_eps,
      :LANGTAG,
      "^^"],
    :_RDFLiteral_2 => [
      :LANGTAG,
      "^^"],
    :_RDFLiteral_3 => [
      "^^"],
    :_RDFLiteral_4 => [
      :LANGTAG,
      :_eps,
      "^^"],
    :String => [
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :base => [
      :BASE],
    :_base_1 => [
      ".",
      :_eps],
    :_base_2 => [
      :IRIREF],
    :_base_3 => [
      ".",
      :_eps],
    :blankNodePropertyList => [
      "["],
    :_blankNodePropertyList_1 => [
      "A",
      "a",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_blankNodePropertyList_2 => [
      "]"],
    :collection => [
      "("],
    :_collection_1 => [
      :_eps,
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_collection_2 => [
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_collection_3 => [
      ")",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_collection_4 => [
      :_eps,
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_collection_5 => [
      ")"],
    :directive => [
      :PREFIX,
      :BASE],
    :_empty => [
      :_eps],
    :graph => [
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :graphIri => [
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_graph_1 => [
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_graph_10 => [
      :_eps,
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_11 => [
      "."],
    :_graph_12 => [
      "}",
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_13 => [
      :_eps,
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_14 => [
      "."],
    :_graph_15 => [
      "}",
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_16 => [
      "}"],
    :_graph_2 => [
      "{"],
    :_graph_3 => [
      :_eps,
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_4 => [
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_5 => [
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_6 => [
      :_eps,
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_7 => [
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_8 => [
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_9 => [
      "{"],
    :graph_statement => [
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :iri => [
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :literal => [
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :object => [
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :objectList => [
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_objectList_1 => [
      :_eps,
      ","],
    :_objectList_2 => [
      ","],
    :_objectList_3 => [
      ","],
    :_objectList_4 => [
      :_eps,
      ","],
    :_objectList_5 => [
      :_eps,
      ","],
    :_objectList_6 => [
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :predicate => [
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :predicateObjectList => [
      "A",
      "a",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_predicateObjectList_1 => [
      :_eps,
      ";"],
    :_predicateObjectList_2 => [
      ";"],
    :_predicateObjectList_3 => [
      ";"],
    :_predicateObjectList_4 => [
      :_eps,
      "A",
      "a",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_predicateObjectList_5 => [
      "A",
      "a",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_predicateObjectList_6 => [
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_predicateObjectList_7 => [
      :_eps,
      ";"],
    :_predicateObjectList_8 => [
      :_eps,
      "A",
      "a",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_predicateObjectList_9 => [
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :prefixID => [
      :PREFIX],
    :_prefixID_1 => [
      ".",
      :_eps],
    :_prefixID_2 => [
      :PNAME_NS],
    :_prefixID_3 => [
      :IRIREF],
    :_prefixID_4 => [
      ".",
      :_eps],
    :subject => [
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :trigDoc => [
      :_eps,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_trigDoc_1 => [
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_trigDoc_2 => [
      :_eps,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :triples => [
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_triples_1 => [
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_triples_2 => [
      "["],
    :_triples_3 => [
      :_eps,
      "A",
      "a",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_triples_4 => [
      "A",
      "a",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_triples_5 => [
      :_eps,
      "A",
      "a",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :verb => [
      "A",
      "a",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
  }.freeze
  FOLLOW = {
    :BlankNode => [
      "A",
      "a",
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :BooleanLiteral => [
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :NumericLiteral => [
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :PrefixedName => [
      "{",
      "A",
      "a",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ")",
      ",",
      ".",
      "]",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      ";",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :RDFLiteral => [
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_RDFLiteral_1 => [
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_RDFLiteral_2 => [
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_RDFLiteral_3 => [
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_RDFLiteral_4 => [
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :String => [
      :LANGTAG,
      "^^",
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :base => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_base_1 => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_base_2 => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_base_3 => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :blankNodePropertyList => [
      ".",
      "A",
      "a",
      ")",
      ",",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_blankNodePropertyList_1 => [
      ".",
      "A",
      "a",
      ")",
      ",",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_blankNodePropertyList_2 => [
      ".",
      "A",
      "a",
      ")",
      ",",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :collection => [
      "A",
      "a",
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_collection_1 => [
      ")"],
    :_collection_2 => [
      ")"],
    :_collection_3 => [
      "A",
      "a",
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_collection_4 => [
      ")"],
    :_collection_5 => [
      "A",
      "a",
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :directive => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :graph => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :graphIri => [
      "{",
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :_graph_1 => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_graph_10 => [
      "}"],
    :_graph_11 => [
      "}",
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_12 => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_graph_13 => [
      "}"],
    :_graph_14 => [
      "}",
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_15 => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_graph_16 => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_graph_2 => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_graph_3 => [
      "}"],
    :_graph_4 => [
      "}",
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_5 => [
      "}"],
    :_graph_6 => [
      "}"],
    :_graph_7 => [
      "}",
      "[",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      :PNAME_LN,
      :PNAME_NS],
    :_graph_8 => [
      "}"],
    :_graph_9 => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :graph_statement => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :iri => [
      "{",
      "A",
      "a",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ")",
      ",",
      ".",
      "]",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      ";",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :literal => [
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :object => [
      ")",
      ",",
      ".",
      "]",
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      ";",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :objectList => [
      ".",
      "]",
      ";"],
    :_objectList_1 => [
      ".",
      "]",
      ";"],
    :_objectList_2 => [
      ",",
      ".",
      "]",
      ";"],
    :_objectList_3 => [
      ".",
      "]",
      ";"],
    :_objectList_4 => [
      ".",
      "]",
      ";"],
    :_objectList_5 => [
      ".",
      "]",
      ";"],
    :_objectList_6 => [
      ",",
      ".",
      "]",
      ";"],
    :predicate => [
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
    :predicateObjectList => [
      ".",
      "]"],
    :_predicateObjectList_1 => [
      ".",
      "]"],
    :_predicateObjectList_2 => [
      ";",
      ".",
      "]"],
    :_predicateObjectList_3 => [
      ".",
      "]"],
    :_predicateObjectList_4 => [
      ";",
      ".",
      "]"],
    :_predicateObjectList_5 => [
      ";",
      ".",
      "]"],
    :_predicateObjectList_6 => [
      ".",
      "]"],
    :_predicateObjectList_7 => [
      ".",
      "]"],
    :_predicateObjectList_8 => [
      ";",
      ".",
      "]"],
    :_predicateObjectList_9 => [
      ";",
      ".",
      "]"],
    :prefixID => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_prefixID_1 => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_prefixID_2 => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_prefixID_3 => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :_prefixID_4 => [
      :_eof,
      :PREFIX,
      :BASE,
      "{",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :subject => [
      "A",
      "a",
      :IRIREF,
      :PNAME_LN,
      :PNAME_NS],
    :trigDoc => [
      :_eof],
    :_trigDoc_1 => [
      :_eof],
    :_trigDoc_2 => [
      :_eof],
    :triples => [
      "."],
    :_triples_1 => [
      "."],
    :_triples_2 => [
      "."],
    :_triples_3 => [
      "."],
    :_triples_4 => [
      "."],
    :_triples_5 => [
      "."],
    :verb => [
      :IRIREF,
      :BLANK_NODE_LABEL,
      :ANON,
      "(",
      "[",
      :PNAME_LN,
      :PNAME_NS,
      :INTEGER,
      :DECIMAL,
      :DOUBLE,
      "true",
      "false",
      :STRING_LITERAL_QUOTE,
      :STRING_LITERAL_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_SINGLE_QUOTE,
      :STRING_LITERAL_LONG_QUOTE],
  }.freeze
end

