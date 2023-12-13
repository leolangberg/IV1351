package se.kth.iv1351.soundgoodjdbc.model;

/*
 * Instrument here is not exactly the same object as an instrument in database
 *
 */

public class Instrument implements InstrumentDTO {
    
    private int instrument_id;
    private String instrument_name;
    private String instrument_brand;
    private double instrument_cost;
    private int rental_id;
    private String time_rented;
    private String time_returned;
    private Integer student_id;




    public Instrument(int instrument_id, String instrument_name, String instrument_brand, double instrument_cost, int rental_id, String time_rented, Integer student_id) {

        this.instrument_name = instrument_name;
        this.instrument_id = instrument_id;
        this.instrument_brand = instrument_brand;
        this.instrument_cost = instrument_cost;
        this.rental_id = rental_id;
        this.time_rented = time_rented;
        this.time_returned = null;
        this.student_id = student_id;

    }

    public String getInstrumentName() {
        return instrument_name;
    }

    public int getInstrumentID() {
        return instrument_id;
    }

    public String getInstrumentBrand() {
        return instrument_brand;
    }

    public double getInstrumentCost() {
        return instrument_cost;
    }

    public int getRentalID() {
        return rental_id;
    }

    public String getTimeRented() {
        return time_rented;
    }

    public String getTimeReturned () {
        return time_returned;
    }

    public Integer getStudentID() {
        return student_id;
    }
}