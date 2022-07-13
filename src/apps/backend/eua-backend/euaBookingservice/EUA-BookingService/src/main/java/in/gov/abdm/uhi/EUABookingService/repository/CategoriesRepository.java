package in.gov.abdm.uhi.EUABookingService.repository;


import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import in.gov.abdm.uhi.EUABookingService.entity.Categories;


@Repository
public interface CategoriesRepository extends JpaRepository<Categories, Long>{
	
	List<Categories> findByCategoryId(Long categoryid);

}
