package in.gov.abdm.uhi.EUABookingService.serviceImpl;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import in.gov.abdm.uhi.EUABookingService.exceptions.FileStorageException;
import in.gov.abdm.uhi.EUABookingService.exceptions.MyFileNotFoundException;
@Component
public class FileStorageService {
	
	
	Logger logger = LogManager.getLogger(FileStorageService.class);
    private  Path fileStorageLocation;

    public String storeFile(MultipartFile file,String path) {
       
        String fileName = StringUtils.cleanPath(file.getOriginalFilename());
        logger.info("----fileName------"+fileName);

        try {
        	this.fileStorageLocation = Paths.get(path)
                    .toAbsolutePath().normalize();
        	 Files.createDirectories(this.fileStorageLocation);
        	
           
            if(fileName.contains("..")) {
                throw new FileStorageException("Sorry! Filename contains invalid path sequence " + fileName);
            }

          
            Path targetLocation = this.fileStorageLocation.resolve(fileName);
            logger.info("----targetlocation------"+targetLocation);
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

            return fileName;
        } catch (IOException ex) {
        	logger.error("Exception in file storing"+ex);
            throw new FileStorageException("Could not store file " + fileName + ". Please try again!", ex);
        }
    }

    public Resource loadFileAsResource(String fileName,String path) {
        try {
        	this.fileStorageLocation = Paths.get(path)
                    .toAbsolutePath().normalize();
            Path filePath = this.fileStorageLocation.resolve(fileName).normalize();
            Resource resource = new UrlResource(filePath.toUri());
            if(resource.exists()) {
                return resource;
            } else {
                throw new MyFileNotFoundException("File not found " + fileName);
            }
        } catch (MalformedURLException ex) {
        	logger.error("Exception getting file"+ex);
            throw new MyFileNotFoundException("File not found " + fileName, ex);
        }
    }
}