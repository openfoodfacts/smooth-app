import 'dart:io';

/// A very simple Console output abstraction.
/// Allows to print log messages and error messages.
class Console {
  /// Creates an instance with
  const Console(this._output, this._error);

  Console.stdio() : this(stdout, stderr);

  final Stdout _output;

  final Stdout _error;

  /// Writes the [message] to the error sink
  void error(Object message) => _error.supportsAnsiEscapes
      ? _error.writeln('\x1B[31m${message.toString()}\x1B[0m')
      : _error.writeln(message.toString());

  /// Writes the [message] the to the normal output sink
  void log(Object message) => _output.writeln(message.toString());
}
