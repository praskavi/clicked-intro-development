// public with sharing class PDFUtil {
//     public static Blob generatePDF(String billId) {
//         PageReference pageRef = new PageReference('/apex/BillVFP?id=' + billId);
//         return pageRef.getContentAsPDF();
//     }
// }
public class PDFUtil implements IPDFGenerator {
    public Blob generatePDF(String billId) {
        PageReference pageRef = new PageReference('/apex/BillVFP?id=' + billId);
        return pageRef.getContentAsPDF();
    }
}
