package com.empleados.Service;

import com.empleados.Model.Boleta;
import com.empleados.Model.DetalleBoleta;
import com.empleados.Model.Empleado;
import com.empleados.Repository.DetalleBoletaRepository;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;

@Service
public class ExcelService {

	@Autowired
	private DetalleBoletaRepository detalleBoletaRepository;

	public byte[] generarBoletaExcel(Boleta boleta) throws IOException {
		Empleado emp = boleta.getEmpleado();

		try (XSSFWorkbook workbook = new XSSFWorkbook()) {
			Sheet sheet = workbook.createSheet("Boleta de Pago");
			sheet.setColumnWidth(0, 6000);
			sheet.setColumnWidth(1, 6000);

			// Estilos
			CellStyle titleStyle = workbook.createCellStyle();
			Font titleFont = workbook.createFont();
			titleFont.setBold(true);
			titleFont.setFontHeightInPoints((short) 14);
			titleStyle.setFont(titleFont);
			titleStyle.setAlignment(HorizontalAlignment.CENTER);
			titleStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
			titleStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
			Font titleFontWhite = workbook.createFont();
			titleFontWhite.setBold(true);
			titleFontWhite.setFontHeightInPoints((short) 14);
			titleFontWhite.setColor(IndexedColors.WHITE.getIndex());
			titleStyle.setFont(titleFontWhite);

			CellStyle headerStyle = workbook.createCellStyle();
			Font headerFont = workbook.createFont();
			headerFont.setBold(true);
			headerStyle.setFont(headerFont);
			headerStyle.setFillForegroundColor(IndexedColors.LIGHT_BLUE.getIndex());
			headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
			headerStyle.setBorderBottom(BorderStyle.THIN);

			CellStyle labelStyle = workbook.createCellStyle();
			Font labelFont = workbook.createFont();
			labelFont.setBold(true);
			labelStyle.setFont(labelFont);

			CellStyle moneyStyle = workbook.createCellStyle();
			DataFormat format = workbook.createDataFormat();
			moneyStyle.setDataFormat(format.getFormat("#,##0.00"));

			CellStyle totalStyle = workbook.createCellStyle();
			Font totalFont = workbook.createFont();
			totalFont.setBold(true);
			totalStyle.setFont(totalFont);
			totalStyle.setFillForegroundColor(IndexedColors.LIGHT_GREEN.getIndex());
			totalStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
			totalStyle.setDataFormat(format.getFormat("#,##0.00"));

			int row = 0;

			// Título
			Row titleRow = sheet.createRow(row++);
			Cell titleCell = titleRow.createCell(0);
			titleCell.setCellValue("BOLETA DE PAGO");
			titleCell.setCellStyle(titleStyle);
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 1));

			row++; // espacio

			// Datos del empleado
			Row r1 = sheet.createRow(row++);
			Cell l1 = r1.createCell(0);
			l1.setCellValue("Empleado:");
			l1.setCellStyle(labelStyle);
			r1.createCell(1).setCellValue(emp.getUsuario().getNombre() + " " + emp.getUsuario().getApellidopaterno());

			Row r2 = sheet.createRow(row++);
			Cell l2 = r2.createCell(0);
			l2.setCellValue("DNI:");
			l2.setCellStyle(labelStyle);
			r2.createCell(1).setCellValue(emp.getUsuario().getDni());

			Row r3 = sheet.createRow(row++);
			Cell l3 = r3.createCell(0);
			l3.setCellValue("Código:");
			l3.setCellStyle(labelStyle);
			r3.createCell(1).setCellValue(emp.getCodigo());

			Row r4 = sheet.createRow(row++);
			Cell l4 = r4.createCell(0);
			l4.setCellValue("Área:");
			l4.setCellStyle(labelStyle);
			r4.createCell(1).setCellValue(emp.getArea().getNombrearea());

			Row r5 = sheet.createRow(row++);
			Cell l5 = r5.createCell(0);
			l5.setCellValue("Periodo:");
			l5.setCellStyle(labelStyle);
			r5.createCell(1).setCellValue(boleta.getPeriodo());

			Row r6 = sheet.createRow(row++);
			Cell l6 = r6.createCell(0);
			l6.setCellValue("Fecha Emisión:");
			l6.setCellStyle(labelStyle);
			r6.createCell(1).setCellValue(boleta.getFechaemision().toString());

			row++; // espacio

			// Encabezado de conceptos
			Row headerRow = sheet.createRow(row++);
			Cell h1 = headerRow.createCell(0);
			h1.setCellValue("Concepto");
			h1.setCellStyle(headerStyle);
			Cell h2 = headerRow.createCell(1);
			h2.setCellValue("Monto (S/.)");
			h2.setCellStyle(headerStyle);

			// Detalles
			List<DetalleBoleta> detalles = detalleBoletaRepository.findByBoleta(boleta);
			for (DetalleBoleta detalle : detalles) {
				Row dr = sheet.createRow(row++);
				dr.createCell(0).setCellValue(detalle.getConcepto());
				Cell moneyCell = dr.createCell(1);
				moneyCell.setCellValue(detalle.getMonto().doubleValue());
				moneyCell.setCellStyle(moneyStyle);
			}

			row++; // espacio

			// Total
			Row totalRow = sheet.createRow(row);
			Cell totalLabel = totalRow.createCell(0);
			totalLabel.setCellValue("TOTAL NETO");
			totalLabel.setCellStyle(totalStyle);
			Cell totalValue = totalRow.createCell(1);
			totalValue.setCellValue(boleta.getTotal().doubleValue());
			totalValue.setCellStyle(totalStyle);

			ByteArrayOutputStream out = new ByteArrayOutputStream();
			workbook.write(out);
			return out.toByteArray();
		}
	}
}