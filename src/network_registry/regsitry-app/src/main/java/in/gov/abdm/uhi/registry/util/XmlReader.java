package in.gov.abdm.uhi.registry.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.Iterator;
import java.util.List;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.core.io.ClassPathResource;

import in.gov.abdm.uhi.registry.entity.Cities;
public class XmlReader {
private static String filePath="/static/doc/cityDetails.xlsx";

	public static List<Cities> readXmlFile(){
		try {
			 File files = new ClassPathResource("static/doc/cityDetails.xlsx").getFile();    
			FileInputStream file=new FileInputStream(files );
			Workbook workbook=new XSSFWorkbook(file);
			DataFormatter formatter=new DataFormatter();
			Iterator<Sheet> sheets=workbook.sheetIterator();
			while(sheets.hasNext()) {
				Sheet sh=sheets.next();
				System.out.println("sheet name: "+sh.getSheetName());
				Iterator<Row> itr=sh.iterator();
				while(itr.hasNext()) {
					Row row=itr.next();
					Iterator<Cell> cellitr=row.iterator();
					while(cellitr.hasNext()) {
						Cell cell=cellitr.next();
						if(cell.getCellType()==CellType.STRING) {
							String cellValue=formatter.formatCellValue(cell);
							System.out.print(cellValue);
							
						}
						System.out.println();
					}
				}
				
			}
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return null;
		
	}
	
}
