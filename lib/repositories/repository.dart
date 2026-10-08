abstract interface class Repository<T> {
  Future<List<T>> getAll();

  Future<T?> getById(int id);

  Future<void> add(T item);

  Future<void> update(T item);

  Future<void> delete(int id);
}