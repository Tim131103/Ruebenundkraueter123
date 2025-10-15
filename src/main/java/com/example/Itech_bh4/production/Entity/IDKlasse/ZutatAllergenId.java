package com.example.Itech_bh4.production.Entity.IDKlasse;

import java.io.Serializable;
import java.util.Objects;

public class ZutatAllergenId implements Serializable {
    private Integer allergenNr;
    private Integer zutatenNr;

    public ZutatAllergenId() {}

    public ZutatAllergenId(Integer allergenNr, Integer zutatenNr) {
        this.allergenNr = allergenNr;
        this.zutatenNr = zutatenNr;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ZutatAllergenId that = (ZutatAllergenId) o;
        return Objects.equals(allergenNr, that.allergenNr) &&
               Objects.equals(zutatenNr, that.zutatenNr);
    }

    @Override
    public int hashCode() {
        return Objects.hash(allergenNr, zutatenNr);
    }
}
