import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void go_back_home(BuildContext context) {
  context.go('/home');
}

void pop_or_home(BuildContext context) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go('/home');
}
