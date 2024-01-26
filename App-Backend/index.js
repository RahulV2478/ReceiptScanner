const { MongoClient } = require('mongodb');
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const mongoClient = new MongoClient('mongodb+srv://rahulvuggumudi:tP6NkDl5ddbkxElf@cluster0.aklpiz1.mongodb.net/');

async function main() {
    try {
        // Connect to the MongoDB cluster
        await mongoClient.connect();
        
        // Get database and collection
        const db = mongoClient.db('AppBackend');
        const lawsuitsCollection = db.collection('Lawsuits');

        // REST API routes would go here
        // For example:
        app.get('/Lawsuits', async (req, res) => {
            try {
                const results = await lawsuitsCollection.find({}).toArray();
                console.log("Fetched Lawsuits:", results);
                res.json(results);
            } catch (err) {
                console.error(err);
                res.status(500).json({ error: 'Internal server error' });
            }
        });
        
        
        
        app.post('/search', async (req, res) => {
            const searchText = req.body.text.toLowerCase();
            console.log(searchText);
        
            try {
                // Retrieve all company names from the database
                const companies = await lawsuitsCollection.find({}, { projection: { companyName: 1, _id: 0 } }).toArray();
                console.log(companies);
                // Check if any company name is contained in the searchText
                const foundCompany = companies.find(company => 
                    company.companyName && searchText.includes(company.companyName.toLowerCase())
                );
        
                if (foundCompany) {
                    // Send back the company name if found in the searchText
                    res.json({ matchFound: true, companyName: foundCompany.companyName });
                } else {
                    res.json({ matchFound: false });
                }
            } catch (err) {
                console.error(err);
                res.status(500).json({ error: 'Internal server error' });
            }
        });
        
        
        
        
        
        
        
        

        // Start server
        const PORT = process.env.PORT || 3000;
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });

    } catch (e) {
        console.error(e);
    }
}

main();
