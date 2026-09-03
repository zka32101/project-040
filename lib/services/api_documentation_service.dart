/// Phase 35: API Documentation & SDK Generation サービス実装
///
/// API仕様管理、ドキュメント生成、SDKジェネレーション

import 'package:project_040/models/api_documentation_models.dart';

/// API仕様リポジトリインターフェース
abstract class ApiSpecificationRepository {
  /// API仕様を取得
  Future<ApiSpecification?> getSpecification(String specId);

  /// API仕様を保存
  Future<void> saveSpecification(ApiSpecification spec);

  /// エンドポイントを追加
  Future<void> addEndpoint(String specId, ApiEndpoint endpoint);

  /// エンドポイントを更新
  Future<void> updateEndpoint(String specId, ApiEndpoint endpoint);

  /// エンドポイントを削除
  Future<void> removeEndpoint(String specId, String endpointId);

  /// リソースを追加
  Future<void> addResource(String specId, ApiResource resource);

  /// バージョン別仕様を取得
  Future<ApiSpecification?> getSpecificationByVersion(
    String specId,
    String version,
  );
}

/// メモリ実装のAPI仕様リポジトリ
class MemoryApiSpecificationRepository implements ApiSpecificationRepository {
  final Map<String, ApiSpecification> _specifications = {};
  final Map<String, List<ApiEndpoint>> _endpointsBySpec = {};
  final Map<String, List<ApiVersion>> _versionsBySpec = {};

  @override
  Future<ApiSpecification?> getSpecification(String specId) async {
    return _specifications[specId];
  }

  @override
  Future<void> saveSpecification(ApiSpecification spec) async {
    _specifications[spec.specId] = spec;
    _endpointsBySpec[spec.specId] = List.from(spec.endpoints);
  }

  @override
  Future<void> addEndpoint(String specId, ApiEndpoint endpoint) async {
    final spec = _specifications[specId];
    if (spec != null) {
      final updatedEndpoints = [...spec.endpoints, endpoint];
      final updatedSpec = ApiSpecification(
        specId: spec.specId,
        title: spec.title,
        description: spec.description,
        version: spec.version,
        baseUrl: spec.baseUrl,
        servers: spec.servers,
        license: spec.license,
        contactName: spec.contactName,
        contactEmail: spec.contactEmail,
        contactUrl: spec.contactUrl,
        endpoints: updatedEndpoints,
        resources: spec.resources,
        securitySchemes: spec.securitySchemes,
        createdAt: spec.createdAt,
        updatedAt: DateTime.now(),
      );
      _specifications[specId] = updatedSpec;
      _endpointsBySpec[specId] = updatedEndpoints;
    }
  }

  @override
  Future<void> updateEndpoint(String specId, ApiEndpoint endpoint) async {
    final spec = _specifications[specId];
    if (spec != null) {
      final updatedEndpoints = spec.endpoints
          .map((e) => e.endpointId == endpoint.endpointId ? endpoint : e)
          .toList();
      final updatedSpec = ApiSpecification(
        specId: spec.specId,
        title: spec.title,
        description: spec.description,
        version: spec.version,
        baseUrl: spec.baseUrl,
        servers: spec.servers,
        license: spec.license,
        contactName: spec.contactName,
        contactEmail: spec.contactEmail,
        contactUrl: spec.contactUrl,
        endpoints: updatedEndpoints,
        resources: spec.resources,
        securitySchemes: spec.securitySchemes,
        createdAt: spec.createdAt,
        updatedAt: DateTime.now(),
      );
      _specifications[specId] = updatedSpec;
      _endpointsBySpec[specId] = updatedEndpoints;
    }
  }

  @override
  Future<void> removeEndpoint(String specId, String endpointId) async {
    final spec = _specifications[specId];
    if (spec != null) {
      final updatedEndpoints =
          spec.endpoints.where((e) => e.endpointId != endpointId).toList();
      final updatedSpec = ApiSpecification(
        specId: spec.specId,
        title: spec.title,
        description: spec.description,
        version: spec.version,
        baseUrl: spec.baseUrl,
        servers: spec.servers,
        license: spec.license,
        contactName: spec.contactName,
        contactEmail: spec.contactEmail,
        contactUrl: spec.contactUrl,
        endpoints: updatedEndpoints,
        resources: spec.resources,
        securitySchemes: spec.securitySchemes,
        createdAt: spec.createdAt,
        updatedAt: DateTime.now(),
      );
      _specifications[specId] = updatedSpec;
      _endpointsBySpec[specId] = updatedEndpoints;
    }
  }

  @override
  Future<void> addResource(String specId, ApiResource resource) async {
    final spec = _specifications[specId];
    if (spec != null) {
      final updatedResources = {...spec.resources, resource.name: resource};
      final updatedSpec = ApiSpecification(
        specId: spec.specId,
        title: spec.title,
        description: spec.description,
        version: spec.version,
        baseUrl: spec.baseUrl,
        servers: spec.servers,
        license: spec.license,
        contactName: spec.contactName,
        contactEmail: spec.contactEmail,
        contactUrl: spec.contactUrl,
        endpoints: spec.endpoints,
        resources: updatedResources,
        securitySchemes: spec.securitySchemes,
        createdAt: spec.createdAt,
        updatedAt: DateTime.now(),
      );
      _specifications[specId] = updatedSpec;
    }
  }

  @override
  Future<ApiSpecification?> getSpecificationByVersion(
    String specId,
    String version,
  ) async {
    final spec = _specifications[specId];
    return spec?.version == version ? spec : null;
  }
}

/// API Documentation Serviceインターフェース
abstract class ApiDocumentationService {
  /// ドキュメントを生成 (Markdown形式)
  Future<DocumentationResult> generateMarkdownDocumentation(
    ApiSpecification spec,
    DocumentationConfig config,
  );

  /// OpenAPI仕様をエクスポート
  Future<String> exportOpenApiSpecification(ApiSpecification spec);

  /// エラーコードドキュメントを生成
  Future<String> generateErrorCodeDocumentation(
    List<ApiErrorDefinition> errors,
  );

  /// チェンジログを生成
  Future<String> generateChangelog(List<ChangelogEntry> entries);

  /// APIバージョン互換性をチェック
  Future<Map<String, dynamic>> checkVersionCompatibility(
    ApiSpecification oldSpec,
    ApiSpecification newSpec,
  );
}

/// メモリ実装のAPI Documentation Service
class MemoryApiDocumentationService implements ApiDocumentationService {
  @override
  Future<DocumentationResult> generateMarkdownDocumentation(
    ApiSpecification spec,
    DocumentationConfig config,
  ) async {
    final buffer = StringBuffer();

    // タイトルと説明
    buffer.writeln('# ${config.title}');
    buffer.writeln('');
    buffer.writeln('**Version**: ${spec.version}');
    buffer.writeln('**Base URL**: ${spec.baseUrl}');
    buffer.writeln('');
    buffer.writeln(spec.description);
    buffer.writeln('');

    // 目次
    buffer.writeln('## Table of Contents');
    buffer.writeln('');
    if (config.includeSecurity) buffer.writeln('- [Security](#security)');
    buffer.writeln('- [Endpoints](#endpoints)');
    if (config.includeErrorCodes) buffer.writeln('- [Error Codes](#error-codes)');
    buffer.writeln('');

    // セキュリティ情報
    if (config.includeSecurity && spec.securitySchemes != null) {
      buffer.writeln('## Security');
      buffer.writeln('');
      buffer.writeln('This API uses the following security schemes:');
      buffer.writeln('');
      spec.securitySchemes!.forEach((key, value) {
        buffer.writeln('- **$key**: ${value['type']}');
      });
      buffer.writeln('');
    }

    // エンドポイント
    buffer.writeln('## Endpoints');
    buffer.writeln('');

    for (final endpoint in spec.endpoints) {
      if (endpoint.deprecated) {
        buffer.writeln('### ~~${endpoint.method.value} ${endpoint.path}~~ (Deprecated)');
      } else {
        buffer.writeln('### ${endpoint.method.value} ${endpoint.path}');
      }
      buffer.writeln('');
      buffer.writeln('**Summary**: ${endpoint.summary}');
      buffer.writeln('');
      buffer.writeln('${endpoint.description}');
      buffer.writeln('');

      // パラメータ
      if (endpoint.parameters.isNotEmpty) {
        buffer.writeln('#### Parameters');
        buffer.writeln('');
        for (final param in endpoint.parameters) {
          buffer.writeln(
            '- **${param.name}** (${param.dataType.value}${param.required ? ', required' : ''}): ${param.description}',
          );
        }
        buffer.writeln('');
      }

      // レスポンス
      if (endpoint.responses.isNotEmpty) {
        buffer.writeln('#### Responses');
        buffer.writeln('');
        for (final response in endpoint.responses) {
          buffer.writeln('- **${response.statusCode}**: ${response.description}');
        }
        buffer.writeln('');
      }

      // 例
      if (config.includeExamples) {
        buffer.writeln('#### Example');
        buffer.writeln('');
        buffer.writeln('```bash');
        buffer.writeln(
          'curl -X ${endpoint.method.value} ${spec.baseUrl}${endpoint.path}',
        );
        buffer.writeln('```');
        buffer.writeln('');
      }
    }

    // エラーコード
    if (config.includeErrorCodes) {
      buffer.writeln('## Error Codes');
      buffer.writeln('');
      buffer.writeln('Common error codes are documented separately.');
      buffer.writeln('');
    }

    final content = buffer.toString();

    return DocumentationResult(
      resultId: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      format: config.format,
      title: config.title,
      sections: content.split('## ').length,
      endpoints: spec.endpoints.length,
      content: content,
      generatedAt: DateTime.now(),
    );
  }

  @override
  Future<String> exportOpenApiSpecification(ApiSpecification spec) async {
    final openApiSpec = spec.toOpenApiSpec();
    return _toYaml(openApiSpec);
  }

  @override
  Future<String> generateErrorCodeDocumentation(
    List<ApiErrorDefinition> errors,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('# Error Code Reference');
    buffer.writeln('');

    for (final error in errors) {
      buffer.writeln('## ${error.errorCode}');
      buffer.writeln('');
      buffer.writeln('**Status Code**: ${error.statusCode}');
      buffer.writeln('');
      buffer.writeln('**Message**: ${error.message}');
      buffer.writeln('');
      buffer.writeln('${error.description}');
      buffer.writeln('');
      if (error.solution != null) {
        buffer.writeln('**Solution**: ${error.solution}');
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }

  @override
  Future<String> generateChangelog(List<ChangelogEntry> entries) async {
    final buffer = StringBuffer();
    buffer.writeln('# Changelog');
    buffer.writeln('');

    final entriesByVersion = <String, List<ChangelogEntry>>{};
    for (final entry in entries) {
      entriesByVersion.putIfAbsent(entry.version, () => []).add(entry);
    }

    for (final version in entriesByVersion.keys) {
      buffer.writeln('## [$version]');
      buffer.writeln('');

      final versionEntries = entriesByVersion[version]!;
      final byType = <String, List<ChangelogEntry>>{};
      for (final entry in versionEntries) {
        byType.putIfAbsent(entry.changeType, () => []).add(entry);
      }

      for (final type in byType.keys) {
        buffer.writeln('### ${type.replaceFirst(type[0], type[0].toUpperCase())}');
        buffer.writeln('');
        for (final entry in byType[type]!) {
          buffer.writeln('- ${entry.description}');
        }
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }

  @override
  Future<Map<String, dynamic>> checkVersionCompatibility(
    ApiSpecification oldSpec,
    ApiSpecification newSpec,
  ) async {
    final breaking = <String>[];
    final additions = <String>[];
    final deprecations = <String>[];

    // エンドポイント削除の確認 (breaking change)
    for (final oldEndpoint in oldSpec.endpoints) {
      final stillExists = newSpec.endpoints.any(
        (e) => e.path == oldEndpoint.path && e.method == oldEndpoint.method,
      );
      if (!stillExists) {
        breaking.add('Removed: ${oldEndpoint.method.value} ${oldEndpoint.path}');
      }
    }

    // 新規エンドポイント追加
    for (final newEndpoint in newSpec.endpoints) {
      final isNew = !oldSpec.endpoints.any(
        (e) => e.path == newEndpoint.path && e.method == newEndpoint.method,
      );
      if (isNew) {
        additions.add('Added: ${newEndpoint.method.value} ${newEndpoint.path}');
      }
    }

    // 非推奨マーク
    for (final oldEndpoint in oldSpec.endpoints) {
      final newEndpoint = newSpec.endpoints.firstWhere(
        (e) => e.path == oldEndpoint.path && e.method == oldEndpoint.method,
        orElse: () => oldEndpoint,
      );
      if (!oldEndpoint.deprecated && newEndpoint.deprecated) {
        deprecations
            .add('Deprecated: ${oldEndpoint.method.value} ${oldEndpoint.path}');
      }
    }

    return {
      'isCompatible': breaking.isEmpty,
      'breakingChanges': breaking,
      'additions': additions,
      'deprecations': deprecations,
      'summary':
          'Breaking: ${breaking.length}, Added: ${additions.length}, Deprecated: ${deprecations.length}',
    };
  }

  String _toYaml(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    _appendYaml(buffer, data, 0);
    return buffer.toString();
  }

  void _appendYaml(StringBuffer buffer, dynamic data, int indent) {
    final space = '  ' * indent;

    if (data is Map) {
      data.forEach((key, value) {
        buffer.write('$space$key: ');
        if (value is Map || value is List) {
          buffer.writeln('');
          _appendYaml(buffer, value, indent + 1);
        } else {
          buffer.writeln("'$value'");
        }
      });
    } else if (data is List) {
      for (final item in data) {
        buffer.write('$space- ');
        if (item is Map || item is List) {
          buffer.writeln('');
          _appendYaml(buffer, item, indent + 1);
        } else {
          buffer.writeln("'$item'");
        }
      }
    }
  }
}

/// SDK Generator Serviceインターフェース
abstract class SdkGeneratorService {
  /// SDKを生成
  Future<SdkGenerationResult> generateSdk(
    ApiSpecification spec,
    SdkGenerationConfig config,
  );

  /// 特定のテンプレートを使用してファイルを生成
  Future<String> generateFile(
    String template,
    Map<String, dynamic> context,
  );

  /// サポートされている言語一覧を取得
  List<String> getSupportedLanguages();

  /// 生成されたSDKをパッケージ化
  Future<void> packageSdk(
    SdkGenerationResult result,
    String outputPath,
  );
}

/// メモリ実装のSDK Generator Service
class MemorySdkGeneratorService implements SdkGeneratorService {
  static const List<String> _supportedLanguages = [
    'dart',
    'typescript',
    'python',
    'java',
    'go',
    'rust',
  ];

  @override
  Future<SdkGenerationResult> generateSdk(
    ApiSpecification spec,
    SdkGenerationConfig config,
  ) async {
    final startTime = DateTime.now();
    final generatedFiles = <String>[];
    int totalLines = 0;

    try {
      if (!_supportedLanguages.contains(config.language)) {
        return SdkGenerationResult(
          resultId: 'sdk_${DateTime.now().millisecondsSinceEpoch}',
          language: config.language,
          packageName: config.packageName,
          totalFiles: 0,
          totalLines: 0,
          generatedFiles: [],
          generatedAt: DateTime.now(),
          error: 'Unsupported language: ${config.language}',
          generationTime:
              DateTime.now().difference(startTime),
        );
      }

      // モデル生成
      if (config.generateModels) {
        for (final resource in spec.resources.values) {
          final modelFile = _generateModel(config.language, resource);
          generatedFiles.add('${resource.name.toLowerCase()}_model');
          totalLines += modelFile.split('\n').length;
        }
      }

      // クライアント生成
      if (config.generateClient) {
        final clientFile = _generateClient(config.language, spec);
        generatedFiles.add('${config.packageName}_client');
        totalLines += clientFile.split('\n').length;
      }

      // テスト生成
      if (config.generateTests) {
        for (final endpoint in spec.endpoints) {
          final testFile = _generateTest(config.language, endpoint);
          generatedFiles
              .add('${endpoint.operationIdOrDefault}_test');
          totalLines += testFile.split('\n').length;
        }
      }

      // ドキュメント生成
      if (config.generateDocs) {
        generatedFiles.add('README');
        totalLines += 50;
      }

      return SdkGenerationResult(
        resultId: 'sdk_${DateTime.now().millisecondsSinceEpoch}',
        language: config.language,
        packageName: config.packageName,
        totalFiles: generatedFiles.length,
        totalLines: totalLines,
        generatedFiles: generatedFiles,
        generatedAt: DateTime.now(),
        generationTime: DateTime.now().difference(startTime),
      );
    } catch (e) {
      return SdkGenerationResult(
        resultId: 'sdk_${DateTime.now().millisecondsSinceEpoch}',
        language: config.language,
        packageName: config.packageName,
        totalFiles: 0,
        totalLines: 0,
        generatedFiles: [],
        generatedAt: DateTime.now(),
        error: e.toString(),
        generationTime: DateTime.now().difference(startTime),
      );
    }
  }

  @override
  Future<String> generateFile(
    String template,
    Map<String, dynamic> context,
  ) async {
    var result = template;
    context.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value.toString());
    });
    return result;
  }

  @override
  List<String> getSupportedLanguages() => _supportedLanguages;

  @override
  Future<void> packageSdk(
    SdkGenerationResult result,
    String outputPath,
  ) async {
    // SDKをパッケージ化
  }

  String _generateModel(String language, ApiResource resource) {
    switch (language) {
      case 'dart':
        return '''class ${_toPascalCase(resource.name)} {
  // Properties
  ${_generateDartProperties(resource.schema)}

  ${_toPascalCase(resource.name)}({
    ${_generateDartConstructor(resource.schema)}
  });

  factory ${_toPascalCase(resource.name)}.fromJson(Map<String, dynamic> json) {
    return ${_toPascalCase(resource.name)}(
      ${_generateDartFromJson(resource.schema)}
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ${_generateDartToJson(resource.schema)}
    };
  }
}''';
      case 'typescript':
        return '''export interface ${_toPascalCase(resource.name)} {
  ${_generateTypeScriptInterface(resource.schema)}
}

export class ${_toPascalCase(resource.name)}Client {
  // Implementation
}''';
      case 'python':
        return '''from dataclasses import dataclass

@dataclass
class ${_toPascalCase(resource.name)}:
    ${_generatePythonClass(resource.schema)}''';
      default:
        return '// Generated model for ${resource.name}';
    }
  }

  String _generateClient(String language, ApiSpecification spec) {
    return '''// Generated Client for ${spec.title}
// Version: ${spec.version}

class ${_toPascalCase(spec.title.replaceAll(' ', ''))}Client {
  final String baseUrl = '${spec.baseUrl}';

  // Generated methods for ${spec.endpoints.length} endpoints
  ${spec.endpoints.map((e) => '// ${e.summary}').join('\n  ')}
}''';
  }

  String _generateTest(String language, ApiEndpoint endpoint) {
    return '''// Test for ${endpoint.method.value} ${endpoint.path}

void test${_toPascalCase(endpoint.operationIdOrDefault)}() {
  // Implementation
}''';
  }

  String _generateDartProperties(Map<String, dynamic> schema) {
    return 'final String id;';
  }

  String _generateDartConstructor(Map<String, dynamic> schema) {
    return 'required this.id,';
  }

  String _generateDartFromJson(Map<String, dynamic> schema) {
    return "id: json['id'] as String,";
  }

  String _generateDartToJson(Map<String, dynamic> schema) {
    return "'id': id,";
  }

  String _generateTypeScriptInterface(Map<String, dynamic> schema) {
    return 'id: string;';
  }

  String _generatePythonClass(Map<String, dynamic> schema) {
    return 'id: str';
  }

  String _toPascalCase(String str) {
    return str
        .split(RegExp(r'[-_\s]+'))
        .map((word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join('');
  }
}

/// API Documentation Managerファサード
class ApiDocumentationManager {
  late ApiSpecificationRepository _specRepo;
  late ApiDocumentationService _docService;
  late SdkGeneratorService _sdkService;

  ApiDocumentationManager({
    ApiSpecificationRepository? specRepository,
    ApiDocumentationService? documentationService,
    SdkGeneratorService? sdkGeneratorService,
  }) {
    _specRepo = specRepository ?? MemoryApiSpecificationRepository();
    _docService = documentationService ?? MemoryApiDocumentationService();
    _sdkService = sdkGeneratorService ?? MemorySdkGeneratorService();
  }

  /// API仕様を取得
  Future<ApiSpecification?> getSpec(String specId) =>
      _specRepo.getSpecification(specId);

  /// エンドポイント追加
  Future<void> addEndpoint(String specId, ApiEndpoint endpoint) =>
      _specRepo.addEndpoint(specId, endpoint);

  /// ドキュメント生成
  Future<DocumentationResult> generateDocs(
    ApiSpecification spec,
    DocumentationConfig config,
  ) =>
      _docService.generateMarkdownDocumentation(spec, config);

  /// OpenAPI仕様エクスポート
  Future<String> exportOpenApi(ApiSpecification spec) =>
      _docService.exportOpenApiSpecification(spec);

  /// SDK生成
  Future<SdkGenerationResult> generateSdk(
    ApiSpecification spec,
    SdkGenerationConfig config,
  ) =>
      _sdkService.generateSdk(spec, config);

  /// サポート言語取得
  List<String> supportedLanguages() => _sdkService.getSupportedLanguages();

  /// バージョン互換性チェック
  Future<Map<String, dynamic>> checkCompatibility(
    ApiSpecification oldSpec,
    ApiSpecification newSpec,
  ) =>
      _docService.checkVersionCompatibility(oldSpec, newSpec);
}
