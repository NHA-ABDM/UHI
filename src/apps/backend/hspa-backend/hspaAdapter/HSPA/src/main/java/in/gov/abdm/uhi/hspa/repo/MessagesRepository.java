package in.gov.abdm.uhi.hspa.repo;

import in.gov.abdm.uhi.hspa.models.MessagesModel;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface MessagesRepository extends JpaRepository<MessagesModel, String> {

    Page<MessagesModel> findBySenderAndReceiver(String sender, String Receiver, Pageable p);

}
