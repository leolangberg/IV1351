package se.kth.iv1351.soundgoodjdbc.model;

/**
* Student Object containing student_id & name
*
*
*/
public class Student implements StudentDTO{

    Integer student_id;
    String student_name;
    

    public Student(Integer student_id, String student_name) {

        this.student_id = student_id;
        this.student_name = student_name;
       
    }

    public Integer getStudentID() {
        return student_id;
    }

    public String getStudentName() {
        return student_name;
    }

}