package dev.ryanezil.camel.model;

import java.io.Serializable;

import com.fasterxml.jackson.annotation.JsonProperty;

import io.quarkus.runtime.annotations.RegisterForReflection;

@RegisterForReflection
public class CommonUser implements Serializable {

    @JsonProperty
    private long id;    
    
    @JsonProperty
    private long remoteId;

    @JsonProperty
    private String dni;
    
    @JsonProperty
    private String email;
    
    @JsonProperty
    private String firstName;
    
    @JsonProperty
    private String gender;

    @JsonProperty
    private String lastName;

    @JsonProperty
    private String phone;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getRemoteId() {
        return remoteId;
    }

    public void setRemoteId(long remoteId) {
        this.remoteId = remoteId;
    }

    public String getDni() {
        return dni;
    }

    public void setDni(String dni) {
        this.dni = dni;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    @Override
    public String toString() {
        return "CommonUser [id=" + id + ", remoteId=" + remoteId + ", dni=" + dni + ", email=" + email + ", firstName="
                + firstName + ", gender=" + gender + ", lastName=" + lastName + ", phone=" + phone + "]";
    }

}
