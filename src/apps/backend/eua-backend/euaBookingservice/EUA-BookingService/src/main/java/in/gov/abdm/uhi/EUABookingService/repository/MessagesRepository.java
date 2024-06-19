package in.gov.abdm.uhi.EUABookingService.repository;


import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.EUABookingService.entity.Messages;

@Repository
public interface MessagesRepository extends JpaRepository<Messages, String>{
	
	Page<Messages> findBySenderAndReceiver(String sender,String receiver,Pageable p);

}
