package com.example.Itech_bh4.production.Entity;

import com.example.Itech_bh4.production.Entity.IDKlasse.RezeptZutatID;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "REZEPTZUTAT")
@IdClass(RezeptZutatID.class)
public class RezeptZutat {

    @Id
    @Column(name = "REZEPTNR")
    private Integer rezeptNr;

    @Id
    @Column(name = "ZUTATENNR")
    private Integer zutatenNr;

    @Column(name = "MENGE")
    private Integer menge;

    @Column(name = "EINHEIT", length = 50)
    private String einheit;
}
