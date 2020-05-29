import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

enum Operator {
  ADD,
  SUBSTRACT,
  MULTIPLY,
  DIVIDE,
  EQUALS,
  NONE
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const int MAX_LENGTH = 15;
  static const String ERROR_DIVIDE_BY_ZERO = 'Error: divide by zero';
  Decimal _currentValue = Decimal.parse('0');

  String _integerString;
  String _fractString;

  String _displayedValue = '0';
  bool _insertNewValue = true;
  bool _allowCalculate = true;
  bool _allowBackspace = true;

  Operator _currentOperator = Operator.NONE;
  RegExp _reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

  Function _mathFunc = (Match match) => '${match[1]},';

  void _calculate(Operator _newOperator, String _newValue) {
    setState(() {

      if (_displayedValue == ERROR_DIVIDE_BY_ZERO)
      {
        return;
      }

      if (!_allowCalculate)
      {
        _currentOperator = _newOperator;
        return;
      }

      _newValue = _newValue.replaceAll(',', '');
      Decimal _dValue = Decimal.parse(_newValue);

      _insertNewValue = true;
      _allowBackspace = false;

      if (_currentOperator == Operator.DIVIDE && _dValue == Decimal.parse('0'))
      {
        _displayedValue = ERROR_DIVIDE_BY_ZERO;
        _allowCalculate = false;
        _currentOperator = Operator.NONE;
        _currentValue = Decimal.parse('0');

        return;
      }

      switch (_currentOperator) {
        case Operator.ADD:
          print ('ADD');
          _currentValue += _dValue;
          _allowCalculate = false;
          break;
        case Operator.SUBSTRACT:
          print ('SUBSTRACT');
          _currentValue -= _dValue;
          _allowCalculate = false;
          break;
        case Operator.MULTIPLY:
          print ('MULTIPLY');
          _currentValue *= _dValue;
          _allowCalculate = false;
          break;
        case Operator.DIVIDE:
          print ('DIVIDE');
          _currentValue /= _dValue;
          _allowCalculate = false;
          break;
        case Operator.EQUALS:
          print ('EQUALS');
          _currentValue = _dValue;
          _allowCalculate = true;
          break;
        case Operator.NONE:
          print ('NONE');
          _currentValue = _dValue;
          _allowCalculate = false;
          break;
      }

      _currentOperator = _newOperator;

      _formatText(_currentValue.toString());
    });
  }

  void _updateText(String _newValue)
  {
    String _tempString = _displayedValue.replaceAll(',', '');
    setState(() {

      if (!_insertNewValue && _tempString.length > MAX_LENGTH - 1)
      {
        return;
      }

      if (_newValue == '.')
      {
        if (_insertNewValue)
        {
          _displayedValue = '0.';
          _insertNewValue = false;
          return;
        }
        else if (_displayedValue.contains('.'))
        {
          return;
        }
        else
        {
          _displayedValue += _newValue;
          return;
        }
      }

      if (_newValue == '0' && _displayedValue == '0')
      {
        return;
      }

      if (_insertNewValue)
      {
        _tempString = _newValue;
        _insertNewValue = false;
      }
      else
      {
        _tempString += _newValue;
      }

      _formatText(_tempString);

      _allowCalculate = true;
      _allowBackspace = true;
    }
    );
  }

  void _formatText(String _inValue)
  {
    setState(() {
      if (_inValue.length > MAX_LENGTH || _inValue.contains('e+'))
      {
        _displayedValue = Decimal.parse(_inValue).toStringAsExponential();
      }
      else
      {
        String _tempStr = _inValue;

        final index = _tempStr.indexOf('.');

        if (index >= 0)
        {
          _integerString = _tempStr.substring(0, index);
          _fractString = _tempStr.substring(index + 1, _tempStr.length);
          _integerString = _integerString.toString().replaceAllMapped(_reg, _mathFunc);
          _displayedValue = _integerString + '.' + _fractString;
        }
        else
        {
          _displayedValue = _inValue.toString().replaceAllMapped(_reg, _mathFunc);
        }
      }
    });
  }

  void _negate()
  {
    setState(() {
      if (_displayedValue == ERROR_DIVIDE_BY_ZERO)
      {
        return;
      }

      Decimal _dValue = Decimal.parse(_displayedValue.replaceAll(',', ''));
      _dValue = Decimal.parse('-1.0') * _dValue;
      _formatText(_dValue.toString());
    });
  }

  void _percentage()
  {
    setState(() {
      if (_displayedValue == ERROR_DIVIDE_BY_ZERO)
      {
        return;
      }

      _allowBackspace = false;
      _insertNewValue = true;

      Decimal _dValue = Decimal.parse(_displayedValue.replaceAll(',', ''));
      _dValue = _dValue / Decimal.parse('100.0');
      _formatText(_dValue.toString());
    });
  }

  void _backspace()
  {
    setState(() {

      if (_allowBackspace)
      {
        String _tempStr = _displayedValue.replaceAll(',', '');

        if (_tempStr.length == 1 || (_tempStr.length == 2 && _tempStr.substring(0, 1) == '-' ))
        {
          _tempStr = '0';
          _insertNewValue = true;
        }
        else
        {
          _tempStr = _tempStr.substring(0, _tempStr.length - 1);
        }

        _formatText(_tempStr);
      }
    });
  }

  void _reset()
  {
    setState(() {
      _currentValue = Decimal.parse('0');
      _displayedValue = '0';
      _insertNewValue = true;
      _allowCalculate = true;
      _allowBackspace = true;
      _currentOperator = Operator.NONE;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
//            Text(
//              'current value : $_currentValue',
//              style: Theme.of(context).textTheme.bodyText1,
//            ),
//            Text(
//              'display value : $_displayedValue',
//              style: Theme.of(context).textTheme.bodyText1,
//            ),
//            Text(
//              'current operator : $_currentOperator',
//              style: Theme.of(context).textTheme.bodyText1,
//            ),
//            Text(
//              'allow calculate : $_allowCalculate',
//              style: Theme.of(context).textTheme.bodyText1,
//            ),
            new Row (
              mainAxisAlignment: MainAxisAlignment.end,
                children : <Widget>[
                    Text(
                      //Main Display
                      '$_displayedValue',
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.right,
                    ),
              ],
            ),

            new Divider(
              color: Colors.grey,
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children : <Widget>[
                FlatButton (
                onPressed: () =>_reset(),
                  child: new Text('AC', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: _backspace,
                  child: new Text('⌫', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                onPressed: _percentage,
                  child: new Text('%', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: () => _calculate(Operator.DIVIDE, _displayedValue),
                  child: new Text('÷', style: Theme.of(context).textTheme.headline5,),
                ),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children : <Widget>[
                FlatButton (
                  onPressed: () =>_updateText('7'),
                  child: new Text('7', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: () =>_updateText('8'),
                  child: new Text('8', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: () =>_updateText('9'),
                  child: new Text('9', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: () => _calculate(Operator.MULTIPLY, _displayedValue),
                  child: new Text('x', style: Theme.of(context).textTheme.headline5,),
                ),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children : <Widget>[
                FlatButton (
                  onPressed: () =>_updateText('4'),
                  child: new Text('4', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: () =>_updateText('5'),
                  child: new Text('5', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: () =>_updateText('6'),
                  child: new Text('6', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: () => _calculate(Operator.SUBSTRACT, _displayedValue),
                  child: new Text('-', style: Theme.of(context).textTheme.headline5,),
                ),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children : <Widget>[
                FlatButton (
                  onPressed: () =>_updateText('1'),
                  child: new Text('1', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: () =>_updateText('2'),
                  child: new Text('2', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: () =>_updateText('3'),
                  child: new Text('3', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: () => _calculate(Operator.ADD, _displayedValue),
                  child: new Text('+', style: Theme.of(context).textTheme.headline5,),
                ),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children : <Widget>[
                FlatButton (
                  onPressed: _negate,
                  child: new Text('+/-', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: () =>_updateText('0'),
                  child: new Text('0', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: () =>_updateText('.'),
                  child: new Text('.', style: Theme.of(context).textTheme.headline5,),
                ),
                FlatButton (
                  onPressed: () => _calculate(Operator.EQUALS, _displayedValue),
                  child: new Text('=', style: Theme.of(context).textTheme.headline5,),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
