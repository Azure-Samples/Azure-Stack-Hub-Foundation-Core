using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Newtonsoft.Json.Linq;
using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web;

namespace ARMApplication
{
    class Cloud
    {
        /// <summary>
        /// The token
        /// </summary>
        private string _token;
        /// <summary>
        /// Gets or sets the login endpoint.
        /// </summary>
        /// <value>
        /// The login endpoint.
        /// </value>
        public string loginEndpoint { get; set; }
        /// <summary>
        /// Gets or sets the arm resource identifier.
        /// </summary>
        /// <value>
        /// The arm resource identifier.
        /// </value>
        public string armResourceId { get; set; }
        /// <summary>
        /// Gets or sets the arm endpoint.
        /// </summary>
        /// <value>
        /// The arm endpoint.
        /// </value>
        public string armEndpoint { get; set; }
        /// <summary>
        /// Gets or sets the arm API version.
        /// </summary>
        /// <value>
        /// The arm API version.
        /// </value>
        public string armApiVersion { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="Cloud"/> class.
        /// </summary>
        public Cloud() {}

        /// <summary>
        /// Uses ADAL to authenticate the Service Principal and returns the Authentication Result.
        /// </summary>
        /// <returns>
        /// Authentication Result containing the Access Token
        /// </returns>
        /// <exception cref="InvalidOperationException">Could not get the token</exception>
        private async Task<AuthenticationResult> AuthenticateAsync(string clientId, string clientSecret, string directoryTenantName)
        {
            var cc = new ClientCredential(clientId, clientSecret);
            var context = new AuthenticationContext(String.Concat(this.loginEndpoint.TrimEnd('/'), "/", directoryTenantName));
            var authenticationResult = await context.AcquireTokenAsync(this.armResourceId, cc);
            if (authenticationResult == null)
            {
                throw new InvalidOperationException("Could not get the token");
            }
            return authenticationResult;
        }

        /// <summary>
        /// Sets the authentication endpoints.
        /// </summary>
        private void SetAuthenticationEndpoints()
        {
            string url = String.Format("{0}/metadata/endpoints?api-version=1.0", this.armEndpoint);
            HttpClient client = new HttpClient();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.GetAsync(url).Result;
            JObject joResponse = JObject.Parse(response.Content.ReadAsStringAsync().Result);
            this.loginEndpoint = (joResponse["authentication"])["loginEndpoint"].ToString();
            this.armResourceId = (joResponse["authentication"])["audiences"][0].ToString();
        }

        /// <summary>
        /// Authenticates the Service Principal and sets the token variable.
        /// </summary>
        public void Authenticate(string clientId, string clientSecret, string directoryTenantName)
        {
            SetAuthenticationEndpoints();
            Task<AuthenticationResult> response = AuthenticateAsync(clientId, clientSecret, directoryTenantName);
            _token = response.Result.AccessToken;
        }

        /// <summary>
        /// Gets the token.
        /// </summary>
        /// <returns></returns>
        public string GetToken()
        {
            return _token;
        }

        /// <summary>
        /// Lists all the subscriptions.
        /// </summary>
        /// <returns></returns>
        public string ListSubscriptions()
        {
            string url = String.Format("{0}subscriptions?api-version={1}",
                armEndpoint, armApiVersion);

            return CallAPI(url);
        }

        /// <summary>
        /// Gets the subscription by the subscription identifier.
        /// </summary>
        /// <param name="subscriptionId">The subscription identifier.</param>
        /// <returns></returns>
        public string GetSubscriptionById(string subscriptionId)
        {
            string url = String.Format("{0}subscriptions/{1}?api-version={2}",
                armEndpoint, subscriptionId, armApiVersion);

            return CallAPI(url);
        }

        /// <summary>
        /// Lists all the resource groups.
        /// </summary>
        /// <param name="subscriptionId">The subscription identifier.</param>
        /// <returns></returns>
        public string ListResourceGroups(string subscriptionId)
        {
            string url = String.Format("{0}subscriptions/{1}/resourcegroups?api-version={2}",
                armEndpoint, subscriptionId, armApiVersion);

            return CallAPI(url);
        }

        /// <summary>
        /// Gets the name of the resource group by its Name.
        /// </summary>
        /// <param name="subscriptionId">The subscription identifier.</param>
        /// <param name="resourceGroupName">Name of the resource group.</param>
        /// <returns></returns>
        public string GetResourceGroupByName(string subscriptionId, string resourceGroupName)
        {
            string url = String.Format("{0}subscriptions/{1}/resourcegroups/{2}?api-version={3}",
                armEndpoint, subscriptionId, resourceGroupName, armApiVersion);

            return CallAPI(url);
        }

        /// <summary>
        /// Lists the resources in resource group.
        /// </summary>
        /// <param name="subscriptionId">The subscription identifier.</param>
        /// <param name="resourceGroupName">Name of the resource group.</param>
        /// <returns></returns>
        public string ListResourcesInResourceGroup(string subscriptionId, string resourceGroupName)
        {
            string url = String.Format("{0}subscriptions/{1}/resourcegroups/{2}/resources?api-version={3}",
                armEndpoint, subscriptionId, resourceGroupName, armApiVersion);

            return CallAPI(url);
        }

        /// <summary>
        /// Lists all the resources in a namespace within a resource group.
        /// </summary>
        /// <param name="subscriptionId">The subscription identifier.</param>
        /// <param name="resourceGroupName">Name of the resource group.</param>
        /// <param name="resourceNamespace">The resource namespace.</param>
        /// <param name="resourceTypeName">Name of the resource type.</param>
        /// <param name="apiVersion">The API version.</param>
        /// <returns></returns>
        public string ListResourcesByNamespaceInResourceGroup(string subscriptionId, string resourceGroupName, string resourceNamespace, string resourceTypeName, string apiVersion)
        {
            string url = String.Format("{0}subscriptions/{1}/resourcegroups/{2}/providers/{3}/{4}?api-version={5}",
                armEndpoint, subscriptionId, resourceGroupName, resourceNamespace, resourceTypeName, apiVersion);

            return CallAPI(url);
        }

        /// <summary>
        /// Lists the name of the resource by Name.
        /// </summary>
        /// <param name="subscriptionId">The subscription identifier.</param>
        /// <param name="resourceGroupName">Name of the resource group.</param>
        /// <param name="resourceNamespace">The resource namespace.</param>
        /// <param name="resourceTypeName">Name of the resource type.</param>
        /// <param name="resourceName">Name of the resource.</param>
        /// <param name="apiVersion">The API version.</param>
        /// <returns></returns>
        public string ListResourceByName(string subscriptionId, string resourceGroupName, string resourceNamespace, string resourceTypeName, string resourceName, string apiVersion)
        {
            string url = String.Format("{0}subscriptions/{1}/resourcegroups/{2}/providers/{3}/{4}/{5}?api-version={6}",
                armEndpoint, subscriptionId, resourceGroupName, resourceNamespace, resourceTypeName, resourceName, apiVersion);

            return CallAPI(url);
        }
        /// <summary>
        /// Lists the usage.
        /// </summary>
        /// <param name="subscriptionId">The subscription identifier.</param>
        /// <param name="resourceNamespace">The resource namespace.</param>
        /// <param name="resourceTypeName">Name of the resource type.</param>
        /// <param name="apiVersion">The API version.</param>
        /// <param name="reportedStartTime">The reported start time.</param>
        /// <param name="reportedEndTime">The reported end time.</param>
        /// <returns></returns>
        public string ListUsage(string subscriptionId, string resourceNamespace, string resourceTypeName, string apiVersion, DateTime reportedStartTime, DateTime reportedEndTime)
        {
            string url = string.Format("{0}subscriptions/{1}/providers/{2}/{3}?api-version={4}&reportedstartTime={5}&reportedEndTime={6}",
                  armEndpoint, subscriptionId, resourceNamespace, resourceTypeName, apiVersion, 
                  HttpUtility.UrlEncode(reportedStartTime.ToString("yyyy-MM-ddTHH:mm:ssZ")), HttpUtility.UrlEncode(reportedEndTime.ToString("yyyy-MM-ddTHH:mm:ssZ")));

            return CallAPI(url);
        }

        public string ListRateCard(string subscriptionId, string resourceNamespace, string resourceTypeName, string apiVersion)
        {
            string url = string.Format("{0}subscriptions/{1}/providers/{2}/{3}?api-version={4}&$filter=OfferDurableId eq 'MS-AZR-0003p' and Currency eq 'USD' and Locale eq 'en-US' and RegionInfo eq 'US'",
                  armEndpoint, subscriptionId, resourceNamespace, resourceTypeName, apiVersion);

            return CallAPI(url);
        }
        /// <summary>
        /// Calls the API.
        /// </summary>
        /// <param name="url">The URL.</param>
        /// <param name="urlParameters">The URL parameters.</param>
        /// <returns></returns>
        public string CallAPI(string url)
        {
            try
            {
                HttpClient client = new HttpClient();
                //client.BaseAddress = new Uri(url);
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _token);

                // Add an Accept header for JSON format.
                client.DefaultRequestHeaders.Accept.Add(
                new MediaTypeWithQualityHeaderValue("application/json"));

                // List data response.
                HttpResponseMessage response = client.GetAsync(url).Result;
                //TODO: Deserialize responses into appropriate Json objects as needed
                //dynamic parsedResponse = JObject.Parse(response.Content.ReadAsStringAsync().Result);
                return (response.IsSuccessStatusCode ? response.Content.ReadAsStringAsync().Result : String.Concat(response.StatusCode, response.ReasonPhrase));
            }
            catch (Exception e)
            {
               return String.Format("{0} \n\n{1}", e.Message, e.InnerException != null ? e.InnerException.Message : "");
               
            }
        }

    }
}
