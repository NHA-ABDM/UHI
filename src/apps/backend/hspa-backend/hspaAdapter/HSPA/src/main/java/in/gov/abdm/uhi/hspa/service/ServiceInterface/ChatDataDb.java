package in.gov.abdm.uhi.hspa.service.ServiceInterface;

import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.hspa.models.MessagesModel;

import java.util.List;

public interface ChatDataDb {
	
MessagesModel saveChatDataInDb(Request request) throws Exception;
List<MessagesModel> getMessageDetails();
List<MessagesModel> getMessagesBetweenTwo(String sender, String receiver, Integer pageNumber, Integer pageSize);


	

	

}
