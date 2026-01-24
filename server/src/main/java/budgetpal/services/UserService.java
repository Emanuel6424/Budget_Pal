package budgetpal.services;

import java.util.*;

import org.springframework.stereotype.Service;

import budgetpal.controllers.UserController.UserResponse;
import budgetpal.models.User;
import budgetpal.repositories.UserRepository;

@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService (UserRepository userRepository){
        this.userRepository = userRepository;
    }

    public User save (User u){
        return userRepository.save(u);
    }

    public void delete (User u){
        userRepository.delete(u);
    }

    public Optional<User> findById (Integer id){
        return userRepository.findById(id);
    }

    public Optional<User> findByEmail (String email){
        return userRepository.findByEmail(email);
    }

    public List<User> findAll (){
        List<User> users = new ArrayList<>();
        userRepository.findAll().forEach((s) -> users.add(s));
        return users;
    }

    public UserResponse toUserReponseBuilder(User u){

        return new UserResponse(
            u.getId(),
            u.getFirstName(),
            u.getLastName(),
            u.getEmail(),
            u.getCreatedAt(),
            u.getUpdatedAt()
        );
    }
}
