// 定义一个通用的适配器类
abstract class IsarAdapter<T> {
  // 转换第三方类到 Isar 类
  T fromThirdPartyClass(dynamic thirdPartyClass);

  // 转换 Isar 类到第三方类
  dynamic toThirdPartyClass(T isarClass);
}

// 实现 IsarAdapter，用于通用的转换
class GenericIsarAdapter<T> implements IsarAdapter<T> {
  final T Function(dynamic thirdPartyClass) fromThirdPartyClassImpl;
  final dynamic Function(T isarClass) toThirdPartyClassImpl;

  GenericIsarAdapter({
    required this.fromThirdPartyClassImpl,
    required this.toThirdPartyClassImpl,
  });

  @override
  T fromThirdPartyClass(dynamic thirdPartyClass) {
    return this.fromThirdPartyClassImpl(thirdPartyClass);
  }

  @override
  dynamic toThirdPartyClass(T isarClass) {
    return this.toThirdPartyClassImpl(isarClass);
  }
}
