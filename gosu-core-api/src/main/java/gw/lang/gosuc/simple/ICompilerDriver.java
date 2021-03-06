package gw.lang.gosuc.simple;

import java.io.File;
import java.util.List;
import javax.tools.Diagnostic;

/**
 * @author dpetrusca
 */
public interface ICompilerDriver {
  public static final int ERROR = 0;
  public static final int WARNING = 1;

  void sendCompileIssue(File file, int category, long offset, long line, long column, String message);

  default void sendCompileIssue(Object file, int category, long offset, long line, long column, String message)
  {
    sendCompileIssue( (File)file, category, offset, line, column, message );
  }

  default void sendCompileIssue( Diagnostic d )
  {
  }

  void registerOutput(File sourceFile, File outputFile);
  
  default void registerOutput(Object sourceFile, File outputFile) 
  {
    registerOutput( (File) sourceFile, outputFile);
  }

  default boolean isIncludeWarnings()
  {
    throw new UnsupportedOperationException();
  }

  default boolean hasErrors() 
  {
    throw new UnsupportedOperationException();
  }

  default List<String> getErrors() 
  {
    throw new UnsupportedOperationException();
  }

  default List<String> getWarnings() 
  {
    throw new UnsupportedOperationException();
  }
}
