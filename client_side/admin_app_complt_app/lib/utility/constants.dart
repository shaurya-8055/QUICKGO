import 'package:flutter/material.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);
const defaultPadding = 16.0;

// Use dart-define API_BASE_URL if provided, otherwise fallback to localhost
const String _DEFAULT_URL = 'http://localhost:3000';
const String MAIN_URL =
    String.fromEnvironment('API_BASE_URL', defaultValue: _DEFAULT_URL);
