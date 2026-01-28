import 'package:flutter/material.dart';

class UkBank {
  final String id;
  final String name;
  final String short;
  final Color a;
  final Color b;

  const UkBank({
    required this.id,
    required this.name,
    required this.short,
    required this.a,
    required this.b,
  });
}

// ✅ UK banks list (portfolio-realistic)
const ukBanks = <UkBank>[
  UkBank(id: "barclays", name: "Barclays", short: "B", a: Color(0xFF00AEEF), b: Color(0xFF0057B8)),
  UkBank(id: "hsbc", name: "HSBC UK", short: "HSBC", a: Color(0xFFFF1A1A), b: Color(0xFFB30000)),
  UkBank(id: "lloyds", name: "Lloyds Bank", short: "L", a: Color(0xFF007A3D), b: Color(0xFF00B140)),
  UkBank(id: "natwest", name: "NatWest", short: "NW", a: Color(0xFF6A1B9A), b: Color(0xFF3F51B5)),
  UkBank(id: "santander", name: "Santander", short: "S", a: Color(0xFFD71920), b: Color(0xFF8B0000)),
  UkBank(id: "halifax", name: "Halifax", short: "H", a: Color(0xFF0B3D91), b: Color(0xFF00A3E0)),
  UkBank(id: "nationwide", name: "Nationwide", short: "N", a: Color(0xFF1E3A8A), b: Color(0xFF4F46E5)),
  UkBank(id: "starling", name: "Starling Bank", short: "SB", a: Color(0xFF5A2CA0), b: Color(0xFF00D1D1)),
  UkBank(id: "monzo", name: "Monzo", short: "M", a: Color(0xFFFF2E93), b: Color(0xFFFF6B6B)),
  UkBank(id: "tsb", name: "TSB", short: "TSB", a: Color(0xFF00B2A9), b: Color(0xFF006F6B)),
  UkBank(id: "rbs", name: "Royal Bank of Scotland", short: "RBS", a: Color(0xFF007A5E), b: Color(0xFF3D1A78)),
];
