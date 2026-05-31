import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/repositories/product_repository.dart';
import 'package:fresh_market/domain/usecases/product/delete_product.usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements ProductRepository {}

void main() {
  late DeleteProductUseCase useCase;
  late MockRepo mockRepo;

  setUp(() {
    mockRepo = MockRepo();
    useCase = DeleteProductUseCase(repository: mockRepo);
  });

  test('deletes product successfully', () async {
    when(() => mockRepo.deleteProduct('prod_001'))
        .thenAnswer((_) async => const Success(null));

    final result = await useCase('prod_001');

    expect(result, isA<Success<void>>());
    verify(() => mockRepo.deleteProduct('prod_001')).called(1);
  });

  test('forwards repository failure', () async {
    when(() => mockRepo.deleteProduct('prod_001'))
        .thenAnswer((_) async => Failure(
              FirestoreException(message: 'Not found'),
            ));

    final result = await useCase('prod_001');

    expect(result, isA<Failure<void>>());
    expect((result as Failure).error.message, 'Not found');
  });
}
