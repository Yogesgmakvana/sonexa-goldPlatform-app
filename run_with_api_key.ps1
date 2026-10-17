param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$FlutterArgs
)

flutter run --dart-define-from-file=api_keys.local.json @FlutterArgs
