package in.gov.abdm.eua.userManagement.repository;

import in.gov.abdm.eua.userManagement.model.Messages;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MessagesRepository extends JpaRepository<Messages, String>{
	
	Page<Messages> findBySenderAndReceiver(String sender,String Receiver,Pageable p);

}
