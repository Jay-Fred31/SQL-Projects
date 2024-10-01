CREATE TABLE petadoptiondata (
	PetID int primary key,
	PetType varchar(25),
	Breed varchar(25),
	Agemonths int,
	Color varchar(15),
	Size varchar(25),
	WeightKg numeric,
	Vaccinated int,
	HealthCondition int,
	TimeInShelterDays int,
	AdoptionFee int,	
	PreviousOwner int,	
	AdoptionLikelihood int

);

SELECT * FROM petadoptiondata;

/* What are the most common pet types available for adoption, 
and how does their average age compare? */

SELECT DISTINCT pettype, ROUND(AVG(agemonths)::numeric, 2) AS avg_age_in_months
FROM petadoptiondata
GROUP BY pettype
ORDER BY avg_age_in_months DESC;

/* How does the vaccination status affect the likelihood of adoption? */

SELECT
SUM(CASE WHEN vaccinated > 0 AND adoptionlikelihood > 0 THEN 1 ELSE 0 END
	 ) AS Adopted,
	 count(petid),
SUM(CASE WHEN vaccinated > 0 AND adoptionlikelihood = 0 THEN 1 ELSE 0 END
	 ) AS vaccinatedNotadopted,
SUM(CASE WHEN vaccinated = 0 AND adoptionlikelihood > 0 THEN 1 ELSE 0 END
	 ) AS Notvaccinateadopted,
SUM(CASE WHEN vaccinated = 0 AND adoptionlikelihood = 0 THEN 1 ELSE 0 END
	 ) AS NOvaccinationoradoption
FROM petadoptiondata;


/* Which breeds have the highest adoption fees, and how long do they
typically stay in the shelter? */

SELECT 
	DISTINCT pettype AS pet, 
	MAX(adoptionfee) AS Highest_adoption_fee,
	ROUND(AVG(timeinshelterdays)::NUMERIC, 2) AS days_in_shelter
FROM petadoptiondata
GROUP BY pettype
ORDER BY 2 DESC;
