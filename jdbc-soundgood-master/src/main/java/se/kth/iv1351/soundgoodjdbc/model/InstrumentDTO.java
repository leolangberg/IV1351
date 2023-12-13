package se.kth.iv1351.soundgoodjdbc.model;

/* 
 * DATA TRANSFER OBJECT (DTO)
 * specifies a read-only view of an Instrument.
 */
public interface InstrumentDTO {
    
    public String getInstrumentName();

    public int getInstrumentID();

    public String getInstrumentBrand();

    public double getInstrumentCost();

    public int getRentalID();

    public String getTimeRented();

    public String getTimeReturned();

    public Integer getStudentID();
}
