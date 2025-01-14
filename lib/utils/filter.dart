import 'package:cloud_firestore/cloud_firestore.dart';

Filter fromListFilter(List<Filter> filters, [operator = Filter.and]) {
  Filter filter;
  switch (filters.length) {
    case 1:
      filter = filters[0];
      break;
    case 2:
      filter = operator(filters[0], filters[1]);
      break;
    case 3:
      filter = operator(filters[0], filters[1], filters[2]);
      break;
    case 4:
      filter = operator(filters[0], filters[1], filters[2], filters[3]);
      break;
    case 5:
      filter =
          operator(filters[0], filters[1], filters[2], filters[3], filters[4]);
      break;
    case 6:
      filter = operator(filters[0], filters[1], filters[2], filters[3],
          filters[4], filters[5]);
      break;
    case 7:
      filter = operator(filters[0], filters[1], filters[2], filters[3],
          filters[4], filters[5], filters[6]);
      break;
    case 8:
      filter = operator(filters[0], filters[1], filters[2], filters[3],
          filters[4], filters[5], filters[6], filters[7]);
      break;
    case 9:
      filter = operator(filters[0], filters[1], filters[2], filters[3],
          filters[4], filters[5], filters[6], filters[7], filters[8]);
      break;
    case 10:
      filter = operator(
          filters[0],
          filters[1],
          filters[2],
          filters[3],
          filters[4],
          filters[5],
          filters[6],
          filters[7],
          filters[8],
          filters[9]);
      break;
    default:
      throw ArgumentError(
          "filters lenght`${filters.length}`must be between 1 and 10 !");
  }
  return filter;
}
