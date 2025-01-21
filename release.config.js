module.exports = {
  branches: ['main'], // Define the branches for releases
  plugins: [
    '@semantic-release/commit-analyzer', // Analyze commit messages to determine the release type
    '@semantic-release/release-notes-generator', // Generate release notes
    '@semantic-release/changelog', // Update the CHANGELOG.md file
    '@semantic-release/github', // Create GitHub releases and tags
  ],
};
