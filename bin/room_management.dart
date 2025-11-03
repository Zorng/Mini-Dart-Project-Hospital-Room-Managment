import 'package:room_management/domain/dummy.dart';
import 'package:room_management/data/data_reader.dart';
import 'package:room_management/ui/paginator.dart';
import 'package:room_management/ui/table.dart';

void main() {
  DataReader d1 = DataReader();
  Hosptial h1 = d1.loadData();
  var roomColumns = <Column<Room>>[
    Column<Room>(title: "Room Number", width: 15, data: (r)=>r.roomNumber),
    Column<Room>(title: "Status", width: 10, data: (r)=>r.status),
    Column<Room>(title: "Type", width:  10, data: (r)=>r.type),
  ];
  Table <Room> t1 = Table(items: h1.rooms, columns: roomColumns);
  Paginator.paginate(t1);
  
  
}