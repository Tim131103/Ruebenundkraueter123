package com.example.Itech_bh4.production.Entity.IDKlasse;

import java.io.Serializable;
import java.util.Objects;

public class RezeptZutatID implements Serializable {
    Integer rezeptNr;
    Integer zutatenNr;

    public RezeptZutatID() {}

    public RezeptZutatID(Integer rezeptNr, Integer zutatenNr) {
        this.rezeptNr = rezeptNr;
        this.zutatenNr = zutatenNr;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        RezeptZutatID that = (RezeptZutatID) o;
        return Objects.equals(rezeptNr, that.rezeptNr) && Objects.equals(zutatenNr, that.zutatenNr);
    }

    @Override
    public int hashCode() {
        return Objects.hash(rezeptNr, zutatenNr);
    }
}
