package budgetpal.repositories;

import java.util.Optional;

import org.springframework.data.repository.CrudRepository;

import budgetpal.models.User;

public interface UserRepository extends CrudRepository<User, Integer> {
    public Optional<User> findByEmail(String email);
}
