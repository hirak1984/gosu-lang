package gw.lang.enhancements

uses javax.script.Bindings
uses dynamic.Dynamic
uses gw.lang.reflect.json.Json

enhancement CoreBindingsEnhancement : Bindings {
  /**
   * Generates a static type corresponding with this Bindings object.  The generated type is a nesting of Gosu structure types.
   * This nesting of types is intended to be placed in a .gs file as a top-level structure, or embedded as an inner type.
   *<p>
   * A structure type is a direct mapping of property members to name/value pairs in a Bindings.  A property has the same name as the key and follows these rules:
   * <ul>
   *   <li> If the type of the value is a "simple" type, such as a String or Integer, the type of the property matches the simple type exactly
   *   <li> Otherwise, if the value is a Bindings type, the property type is that of a child structure with the same name as the property and recursively follows these rules
   *   <li> Otherwise, if the value is a List, the property is a List parameterized with the component type where the component type is the structural union inferred from the values of the List recursively following these rules for each value
   * </ul>
   */
  function toStructure( nameForStructure: String ) : String {
    return Json.makeStructureTypes( nameForStructure, this )
  }

  /**
   * Serializes this Bindings instance to a JSON formatted String
   */
  public function toJson() : String {
    var sb = new StringBuilder()
    toJson( sb, 0 )
    return sb.toString()
  }

  /**
   * Serializes this Bindings instance into a JSON formatted StringBuilder with the specified indent of spaces
   */
  public function toJson( sb: StringBuilder, indent: int ) : void {
    var iKey = 0
    if( isNewLine( sb ) ) {
      indent( sb, indent )
    }
    if( this.size() > 0 ) {
      sb.append( "{\n" )
      for( key in this.keySet() ) {
        indent( sb, indent + 2 )
        sb.append( '\"' ).append( key ).append( '\"' ).append( ": " )
        var value : Object = this.get( key )
        if( value typeis Bindings ) {
          value.toJson( sb, indent + 2 )
        }
        else if( value typeis List ) {
          handleJsonList( sb, indent, value )
        }
        else {
          appendGosuValue( sb, value )
        }
        appendCommaNewLine( sb, iKey < this.size() - 1 )
        iKey++
      }
    }
    indent( sb, indent )
    sb.append( "}" )
  }

  private function isNewLine( sb: StringBuilder ) : boolean {
    return sb.length() > 0 && sb.charAt( sb.length() -1 ) == '\n'
  }

  private function handleJsonList( sb: StringBuilder, indent: int, value: List ) {
    var length_0 : int = value.size()
    sb.append( '[' )
    if( length_0 > 0 ) {
      sb.append( "\n" )
      var iSize : int = value.size()
      var i = 0
      while( i < iSize ) {
        var comp : Object = value.get(i)
        if( comp typeis Bindings ) {
          comp.toJson( sb, indent + 4 )
        }
        else if( comp typeis List ) {
          handleJsonList( sb, indent + 4, value )
        }
        else {
          indent( sb, indent + 4 )
          appendGosuValue( sb, comp )
        }
        appendCommaNewLine( sb, i < iSize - 1 )
        i++
      }
    }
    indent( sb, indent + 2 )
    sb.append( "]" )
  }

  /**
   * Serializes this Bindings instance to a JSON-like Gosu expression
   */
  public function toGosu() : String {
    var sb = new StringBuilder()
    toGosu( sb, 0 )
    return sb.toString()
  }
  /**
   * Serializes this Bindings instance to a JSON-like Gosu expression
   */
  public function toGosu( sb: StringBuilder, indent: int ) {
    toGosu( true, sb, indent )
  }
  function toGosu( bWithDynamic: boolean, sb : StringBuilder, indent: int ) {
    var iKey = 0
    indent( sb, indent )
    sb.append( "new" ).append( bWithDynamic ? " Dynamic()" : "()" )
    if( this.size() > 0) {
      sb.append(" {\n")
      for( key in this.keySet() ) {
        indent( sb, indent + 2 )
        sb.append( ":" ).append( key ).append( " = " )
        var value : Object = this.get( key )
        if( value typeis Bindings ) {
          value.toGosu( false, sb, indent + 2 )
        } 
        else if( value typeis List ) {
          handleGosuList( sb, indent, value )
        } 
        else {
          appendGosuValue( sb, value )
        }
        appendCommaNewLine( sb, iKey < this.size() - 1 )
        iKey++
      }
    }
    indent( sb, indent )
    sb.append( "}" )
  }
  private function handleGosuList( sb: StringBuilder, indent: int, list: List ) {
    var length_0 : int = list.size()
    sb.append( '{' )
    if( length_0 > 0 ) {
      sb.append( "\n" )
      var iSize : int = list.size()
      var i = 0
      while( i < iSize ) {
        var comp : Object = list.get( i )
        if( comp typeis Bindings ) {
          comp.toGosu( false, sb, indent + 4 )
        }
        else if( comp typeis List ) {
          handleGosuList( sb, indent + 4, comp )
        }
        else {
          indent( sb, indent + 4 )
          appendGosuValue( sb, comp )
        }
        appendCommaNewLine( sb, i < iSize - 1 )
        i++
      }
    }
    indent( sb, indent + 2 )
    sb.append( "}" )
  }

  /**
   * Serializes this Bindings instance to XML
   */
  public function toXml() : String {
    return toXml( "object" )
  }
  /**
   * Serializes this Bindings instance to XML
   */
  public function toXml( name: String ) : String {
    var sb = new StringBuilder()
    toXml( name, sb, 0 )
    return sb.toString()
  }
  public function toXml( name: String, sb: StringBuilder, indent: int ) {
    indent( sb, indent )
    sb.append( '<' ).append( name )
    if( this.size() > 0) {
      sb.append( ">\n" )
      for( key in this.keySet() ) {
        var value : Object = this.get( key )
        if( value typeis Bindings ) {
          value.toXml( key, sb, indent + 2 )
        }
        else if( value typeis List ) {
          var length_0 : int = value.size()
          indent( sb, indent + 2 )
          sb.append( "<" ).append( key )
          if( length_0 > 0 ) {
            sb.append( ">\n" )
            for( comp in value ) {
              if( comp typeis Bindings ) {
                comp.toXml( "li", sb, indent + 4 )
              }
              else {
                indent( sb, indent + 4 )
                sb.append( "<li>" ).append( comp ).append( "</li>\n" )
              }
            }
            indent( sb, indent + 2 )
            sb.append( "</" ).append( key ).append( ">\n" )
          }
          else {
            sb.append( "/>\n" )
          }
        }
        else {
          indent( sb, indent + 2 )
          sb.append( '<' ).append( key ).append( ">" )
          sb.append( value )
          sb.append( "</" ).append( key ).append( ">\n" )
        }
      }
      indent( sb, indent )
      sb.append( "</" ).append( name ).append( ">\n" )
    }
    else {
      sb.append( "/>\n" )
    }
  }

  private function appendCommaNewLine( sb: StringBuilder, bComma: boolean ) {
    if( bComma ) {
      sb.append( ',' )
    }
    sb.append( "\n" )
  }

  private function indent( sb : StringBuilder, indent : int ) {
    var i = 0
    while (i < indent) {
      sb.append(' ')
      i++
    }
  }

  private function appendGosuValue( sb: StringBuilder, comp: Object) : StringBuilder {
    if( comp typeis String ) {
      sb.append( '\"' )
      sb.append( gw.util.GosuEscapeUtil.escapeForGosuStringLiteral( comp ) )
      sb.append( '\"' )
    }
    else if( comp typeis Integer ||
             comp typeis Long ||
             comp typeis Double ||
             comp typeis Float ||
             comp typeis Short ||
             comp typeis Character ||
             comp typeis Byte ) {
      sb.append( comp )
    }
    else if( comp == null ) {
      sb.append( "null" )
    }
    else {
      throw new IllegalStateException( "Unsupported expando type: " + comp.getClass() )
    }
    return sb
  }
}