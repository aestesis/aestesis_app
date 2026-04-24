import 'package:flutter/material.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
extension RectExt on Rect {
  Map toJson() => {
        'left': left,
        'top': top,
        'right': right,
        'bottom': bottom,
      };
  static Rect fromJson(Map json) =>
      Rect.fromLTRB(json['left'], json['top'], json['right'], json['bottom']);
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class GetSet<T> {
  T? Function(T?)? _willGet;
  T? Function(T?)? _willSet;
  void Function(T?)? _didSet;
  T? _value;
  T? get value { 
    if (_willGet != null) return _willGet!(_value);
    return _value;
  }
  set value(T? value) {
    if (_willSet != null) value = _willSet!(value);
    _value = value;
    _didSet?.call(value);
  }

  GetSet(
      {T? value,
      T? Function(T?)? willGet,
      T? Function(T?)? willSet,
      void Function(T?)? didSet}) {
    _value = value;
    _willGet = willGet;
    _willSet = willSet;
    _didSet = didSet;
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
