import '../models/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import 'dart:io' show Platform;

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  //when using a controller i cant use initvalue on the textform
  final TextEditingController _imageUrlController = TextEditingController();
  //this controller is not needed if i don't wanna get the value
  //before the form is submitted but since i wanna show the
  // image preview then it is needed
  final FocusNode _imageUrlFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();
  //be sure to clear this focus nodes from memory and editing controllers
  //be sure to also remove all listeners
  final _formKey = GlobalKey<FormState>();
  //we have to create a new object instance bc the
  // original product has final values
  var _editedProduct =
      Product(id: null, title: '', imageUrl: '', description: '', price: 0);
  var _initValues = {
    'title': '',
    'imageUrl': '',
    'description': '',
    'price': ''
  };

  bool isInit = true;
  bool isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    //this listener is put so that when the text field loses focus, the image
    //is updated
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //so that this function runs only the first time the page is loaded
    if (isInit) {
      final passedId = ModalRoute.of(context).settings.arguments as String;
      if (passedId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(passedId);
        _initValues = {
          'title': _editedProduct.title,
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString()
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!_imageUrlController.text.startsWith('http') ||
          !_imageUrlController.text.startsWith('https') &&
              (!_imageUrlController.text.endsWith('.png') &&
                  !_imageUrlController.text.endsWith('.jpg') &&
                  !_imageUrlController.text.endsWith('.jpeg'))) return;
      setState(() {});
    }

    return null; //meaning no errors
  }

  // void _saveForm1() {
  //   final isValid = _formKey.currentState.validate();
  //   if (!isValid) return;
  //   _formKey.currentState.save();
  //
  //   setState(() => isLoading = true);
  //
  //   _editedProduct.id != null
  //       ? Provider.of<ProductsProvider>(context, listen: false)
  //           .updateProduct(_editedProduct.id, _editedProduct)
  //       : Provider.of<ProductsProvider>(context, listen: false)
  //           .addProduct(_editedProduct)
  //           //the error is put in the middle here so that
  //           //if the adding fails we still pop
  //           .catchError((err) {
  //           //remember to return so that you can see the dialog
  //           return showDialog<Null>(
  //               context: context, builder: (ctx) => Text('sth went wrong'));
  //         }).then((_) {
  //           setState(() => isLoading = false);
  //           Navigator.of(context).pop();
  //         });
  // }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();

    setState(() {
      isLoading = true;
    });

    try {
      _editedProduct.id != null
          ? await Provider.of<ProductsProvider>(context, listen: false)
              .updateProduct(_editedProduct.id, _editedProduct)
          : await Provider.of<ProductsProvider>(context, listen: false)
              .addProduct(_editedProduct);
    } catch (e) {
      await showDialog<Null>(
          context: context,
          builder: (ctx) => Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text('An error occurred'),
                  content: Text('Something went wrong'),
                  actions: [
                    FlatButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('Close'))
                  ],
                )
              : AlertDialog(
                  title: Text('An error occurred'),
                  content: Text('Something went wrong'),
                  actions: [
                    FlatButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('Close'))
                  ],
                ));
    } finally {
      setState(() => isLoading = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _editedProduct.id != null
            ? Text('Edit Product')
            : Text('Add Product'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveForm)],
      ),
      //to avoid data loss, we can use a Column wrapped in a single child scroll
      //in place of a listview for forms
      //Textformfield is used together with forms
      body: isLoading
          ? Center(
              child: Platform.isIOS
                  ? CupertinoActivityIndicator()
                  : CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Title',
                        ),
                        initialValue: _initValues['title'],
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_priceFocusNode),
                        onSaved: (val) {
                          _editedProduct = Product(
                              title: val,
                              price: _editedProduct.price,
                              description: _editedProduct.description,
                              imageUrl: _editedProduct.imageUrl,
                              id: _editedProduct.id,
                              isFavorite: _editedProduct.isFavorite);
                        },
                        validator: (value) {
                          if (value.isEmpty)
                            return 'please enter a name for your product';
                          return null; //meaning no errors
                        },
                      ),
                      TextFormField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Price',
                        ),
                        initialValue: _initValues['price'],
                        textInputAction: TextInputAction.next,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_descFocusNode),
                        onSaved: (val) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              price: double.parse(val),
                              description: _editedProduct.description,
                              imageUrl: _editedProduct.imageUrl,
                              id: _editedProduct.id,
                              isFavorite: _editedProduct.isFavorite);
                        },
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Please enter a price for your product';
                          if (double.tryParse(value) == null)
                            return 'please enter a valid number';
                          if (double.parse(value) <= 0)
                            return 'price cannot be less than one';
                          return null; //meaning no errors
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
                        initialValue: _initValues['description'],
                        maxLines: 3,
                        focusNode: _descFocusNode,
                        keyboardType: TextInputType.multiline,
                        onSaved: (val) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              price: _editedProduct.price,
                              description: val,
                              imageUrl: _editedProduct.imageUrl,
                              id: _editedProduct.id,
                              isFavorite: _editedProduct.isFavorite);
                        },
                        validator: (value) {
                          if (value.isEmpty)
                            return 'please enter a description for your product';
                          if (value.length < 10)
                            return 'description should be at least 10 characters long.';
                          return null; //meaning no errors
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? Center(child: Text("Enter URL =>"))
                                : FittedBox(
                                    child:
                                        Image.network(_imageUrlController.text),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  // labelText: 'Image URL',
                                  hintText: 'please paste image URL only!'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onEditingComplete: () {
                                //so that i can see the image preview
                                setState(() {});
                              },
                              onFieldSubmitted: (_) => _saveForm(),
                              onSaved: (val) {
                                _editedProduct = Product(
                                    title: _editedProduct.title,
                                    price: _editedProduct.price,
                                    description: _editedProduct.description,
                                    imageUrl: val,
                                    id: _editedProduct.id,
                                    isFavorite: _editedProduct.isFavorite);
                              },
                              validator: (value) {
                                if (_imageUrlController.text.isEmpty)
                                  return 'please enter an image URL';
                                if (!value.startsWith('http') ||
                                    !value.startsWith('https'))
                                  return 'please enter a valid image URL with https';
                                // if ( !value.endsWith('png') ||
                                //     !value.endsWith('jpg') ||
                                //     !value.endsWith('jpeg') )
                                //   return 'please enter a valid image URL with a suffix';
                                return null; //meaning no errors
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
