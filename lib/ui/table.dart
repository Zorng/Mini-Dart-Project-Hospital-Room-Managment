class Column<T> {
  final String title;
  final int width; // fixed width per column
  final String Function(T) data; // how to render the cell
  const Column({required this.title, required this.width, required this.data});
}


// render rooms to table
class Table<T> {
  String title;
  List<T> items;
  List<Column<T>> columns;
  Table({required this.title, required this.items, required this.columns});

  //give padding to each cell
  String _padding(String data, int width) {
    if (data.length > width) return data.substring(0, width);
    final pad = ' ' * (width - data.length);
    return '$data$pad';
  }

  String _header(List<Column> cols) => '| ${cols.map((c) => _padding(c.title, c.width)).join(' | ')} |';

  String _headerSeparator(List<Column> cols) => '=${cols.map((c) => '=' * (c.width + 2)).join('+')}=';

  String _row<T>(List<Column<T>> cols, T item) => '| ${cols.map((c) => _padding(c.data(item) , c.width, )).join(' | ')} |';

  String _rowSeparator(List<Column> cols) => '+${cols.map((c) => '-' * (c.width + 2)).join('+')}+';

  void printTable(int start, int end) {
    print("\n");
    print(title);
    print(_headerSeparator(columns));
    print(_header(columns));
    print(_headerSeparator(columns));
    for(final item in items.sublist(start, end)) {
      print(_row(columns, item));
      print(_rowSeparator(columns));
    }
  }
}

