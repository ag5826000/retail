import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'body.dart';

class ProductDataTable extends StatefulWidget {
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final int numberOfProducts;
  final String groupBy;
  const ProductDataTable({Key? key, this.rangeStart,required this.numberOfProducts, this.rangeEnd,required this.groupBy}) : super(key: key);

  @override
  _ProductDataTableState createState() => _ProductDataTableState();
}

class _ProductDataTableState extends State<ProductDataTable> {
  bool _sortNameAsc = true;
  bool _sortRevenueAsc = true;
  bool _sortCountAsc = true;
  bool _sortAsc = false;
  int _sortColumnIndex=1;
  Map<String, ProductData> productList = {};
  List<ProductData> products=[];
  Map<String, Map<String, dynamic>> productDetails = {};
  Map<String, String> categoryMap = {};

  Future<void> _fetchCategories() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference categoryCollection = firestore.collection('Category');

    try {
      QuerySnapshot categorySnapshot = await categoryCollection.get();
      for (QueryDocumentSnapshot categoryDoc in categorySnapshot.docs) {
        Map<String, dynamic> categoryData = categoryDoc.data() as Map<String, dynamic>;
        String categoryId = categoryDoc.id;
        String categoryName = categoryData['categoryName'];
        categoryMap[categoryId] = categoryName;
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _getTransactionsTotal(DateTime? start, DateTime? end) async {
    if (start == null || end == null) {
      return;
    }

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user == null) {
      return;
    }

    final String userId = user.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference transactionsCollection = firestore.collection('transactions_$userId');

    try {
      if(widget.groupBy!='name')
      await _fetchCategories();
      QuerySnapshot querySnapshot = await transactionsCollection
          .where('timestamp', isGreaterThanOrEqualTo: start)
          .where('timestamp', isLessThanOrEqualTo: end)
          .get();

      Map<String, ProductData> productList = {};
      Set<String> uniqueProductIds = {};
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        List<dynamic> items = document['items'];
        for (var item in items) {
          uniqueProductIds.add(item['productId']);
        }
      }

      // Fetch product details for the unique product IDs
      final List<DocumentSnapshot> productDocs = await Future.wait(
        uniqueProductIds.map((productId) =>
            firestore.collection('products').doc(productId).get()),
      );

      // Create a map of product details based on product ID

      for (var productDoc in productDocs) {
        productDetails[productDoc.id] = productDoc.data() as Map<String, dynamic>;
      }
      //print(productDetails.toString());
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> jsonData = document.data() as Map<String, dynamic>;

        List<dynamic> items = jsonData['items'];

        for (var item in items) {
          String productID=item['productId'];
          Map<String, dynamic>? productData=productDetails[productID];
          String productName="";
          if(widget.groupBy =='name')
            productName=productData?[widget.groupBy];
          else
            productName=categoryMap[productData?[widget.groupBy]]!;
          int currentItems = item['numOfItem'] as int;
          int productPrice = (item['sellingPrice'] as int) * currentItems;

          productPrice = productPrice.toInt();

          if (productList.containsKey(productName)) {
            productList[productName] = ProductData(
              productName,
              productList[productName]!.revenue + productPrice,
              productList[productName]!.count + currentItems,
            );
          } else {
            productList[productName] = ProductData(productName, productPrice, currentItems);
          }
        }
      }

      var sortedProducts = productList.entries.toList()
        ..sort((a, b) => b.value.revenue.compareTo(a.value.revenue));

      List<ProductData> topProducts = [];
      if(widget.numberOfProducts!=-1) {
        for (var i = 0; i < widget.numberOfProducts &&
            i < sortedProducts.length; i++) {
          topProducts.add(sortedProducts[i].value);
        }
      }
      else
        {
          for (var i = 0; i < sortedProducts.length; i++) {
            topProducts.add(sortedProducts[i].value);
          }
        }

      setState(() {
        products = topProducts;
      });
    } catch (e) {
      print('Error retrieving transactions: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getTransactionsTotal(widget.rangeStart, widget.rangeEnd);
  }

  @override
  Widget build(BuildContext context) {
    var myColumns = [
      DataColumn(
        label: Text(widget.groupBy == "name" ? "Product Name" : "Category Name"),
        onSort: (columnIndex, sortAscending) {
          setState(() {
            _sortColumnIndex = columnIndex;
            _sortAsc = _sortNameAsc = sortAscending;
            _sortData('name');
          });
        },
      ),
      DataColumn(
        label: Text('Revenue'),
        onSort: (columnIndex, sortAscending) {
          setState(() {
            _sortColumnIndex = columnIndex;
            _sortAsc = _sortRevenueAsc = sortAscending;
            _sortData('revenue');
          });
        },
        numeric: true,
      ),
      DataColumn(
        label: Text('Units Sold'),
        onSort: (columnIndex, sortAscending) {
          setState(() {
            _sortColumnIndex = columnIndex;
            _sortAsc = _sortCountAsc = sortAscending;
            _sortData('count');
          });
        },
        numeric: true,
      ),
    ];

    var myRows = products.map((product) {
      return DataRow(cells: [
        DataCell(Text(product.name)),
        DataCell(Text('${product.revenue}')),
        DataCell(Text('${product.count}')),
      ]);
    });

    return Container(
      color: Colors.white,
      width: double.infinity,
      // margin: EdgeInsets.symmetric(horizontal: 00.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DataTable(
            columnSpacing: 10.0,
            columns: myColumns,
            rows: myRows.toList(),
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAsc,
          ),
        ],
      ),
    );
  }




  void _sortData(String column) {
    products.sort((a, b) {
      if (column == 'name') {
        return a.name.compareTo(b.name);
      } else if (column == 'revenue') {
        return a.revenue.compareTo(b.revenue);
      } else if (column == 'count') {
        return a.count.compareTo(b.count);
      }
      return 0;
    });
    if (!_sortAsc) {
      products = products.reversed.toList();
    }
  }
}